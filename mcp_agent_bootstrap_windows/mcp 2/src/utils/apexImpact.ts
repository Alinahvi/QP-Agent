import { promises as fs } from "node:fs";
import type { Dirent } from "node:fs";
import { basename, extname, join, resolve, relative } from "node:path";
import { runCommand, type CommandResult } from "./process.js";
import { gitCandidates } from "./cliPaths.js";
import { resolveProject } from "./projectResolver.js";

const APEX_EXTS = new Set([".cls"]);
const READ_CONCURRENCY = 8;
const DEFAULT_MAX_FILES = 4000;

export type ApexImpactDetails = {
  mode: "manifest" | "git" | "unknown";
  changedClasses: string[];
  changedTestClasses: string[];
  viaReference: string[];
  viaHeuristic: string[];
  totalTestFiles: number;
};

const impactCache = new Map<string, { tests: string[]; details: ApexImpactDetails }>();

function normalizeRelativePath(repoDir: string, filePath: string): string {
  const rel = relative(repoDir, filePath);
  return rel.replace(/\\/g, "/");
}

function isWithinRoots(repoDir: string, filePath: string, roots: string[]): boolean {
  if (!roots.length) return true;
  const rel = normalizeRelativePath(repoDir, filePath);
  return roots.some((root) => rel === root || rel.startsWith(root.endsWith("/") ? root : `${root}/`));
}

async function fileSignature(path: string): Promise<string> {
  try {
    const stat = await fs.stat(path);
    return `${path}:${stat.mtimeMs}:${stat.size}`;
  } catch {
    return `${path}:missing`;
  }
}

function detectApexClassName(src: string): string | null {
  const match = src.match(/\b(class|interface|enum)\s+([A-Za-z0-9_]+)/);
  return match ? match[2] : null;
}

function isApexTestClass(src: string, maybeFilename?: string): boolean {
  if (/\b@IsTest\b/i.test(src) || /\btestMethod\b/i.test(src)) return true;
  if (maybeFilename) {
    const name = basename(maybeFilename, extname(maybeFilename));
    if (/test(s)?$/i.test(name) || /^test/i.test(name) || /_tests?$/i.test(name)) return true;
  }
  return false;
}

function deriveLikelyTestNames(base: string): string[] {
  return [
    `${base}Test`, `${base}Tests`, `${base}_Test`, `${base}_Tests`,
    `Test${base}`, `${base}TestClass`, `${base}UnitTest`, `${base}UT`
  ];
}

async function readFileSafe(path: string): Promise<string> {
  try {
    const buf = await fs.readFile(path);
    return buf.toString("utf8");
  } catch {
    return "";
  }
}

async function listFiles(root: string, exts: Set<string>, max: number, searchRoots?: string[]): Promise<string[]> {
  const results: string[] = [];
  const roots = searchRoots && searchRoots.length
    ? searchRoots.map((r) => resolve(root, r))
    : [root];

  const stack: string[] = [...roots];
  while (stack.length && results.length < max) {
    const dir = stack.pop()!;
    let entries: Dirent[] = [];
    try {
      entries = await fs.readdir(dir, { withFileTypes: true });
    } catch {
      continue;
    }
    for (const entry of entries) {
      if (results.length >= max) break;
      const full = join(dir, entry.name);
      if (entry.isDirectory()) {
        stack.push(full);
      } else {
        const ext = extname(full).toLowerCase();
        if (exts.has(ext)) results.push(full);
      }
    }
  }
  return results;
}

async function runGitDiff(repoDir: string, fromRef: string, toRef: string): Promise<CommandResult | null> {
  let last: CommandResult | null = null;
  for (const git of gitCandidates()) {
    const result = await runCommand(git, ["diff", "--name-only", fromRef, toRef], { cwd: repoDir, timeoutMs: 60_000 });
    last = result;
    if (result.code === 0) return result;
  }
  return last;
}

async function gatherGitChangedClasses(repoDir: string, fromRef: string, toRef: string, roots: string[]) {
  const diffResult = await runGitDiff(repoDir, fromRef, toRef);
  const changedClasses = new Set<string>();
  const changedTestClasses = new Set<string>();
  if (!diffResult || diffResult.code !== 0) {
    return { changedClasses, changedTestClasses };
  }
  const files = diffResult.stdout.split(/\r?\n/).map((s) => s.trim()).filter(Boolean);
  const clsFiles = files
    .filter((f) => f.toLowerCase().endsWith(".cls"))
    .map((f) => resolve(repoDir, f))
    .filter((abs) => isWithinRoots(repoDir, abs, roots));
  const limit = Math.min(READ_CONCURRENCY, Math.max(1, clsFiles.length));
  let index = 0;
  const workers = Array.from({ length: limit }, async () => {
    while (true) {
      const current = index++;
      if (current >= clsFiles.length) break;
      const file = clsFiles[current];
      const src = await readFileSafe(file);
      const name = detectApexClassName(src) || basename(file, ".cls");
      if (!name) continue;
      if (isApexTestClass(src, file)) changedTestClasses.add(name);
      else changedClasses.add(name);
    }
  });
  await Promise.all(workers);
  return { changedClasses, changedTestClasses };
}

async function loadManifestClasses(manifestPath: string): Promise<Set<string>> {
  const xml = await readFileSafe(manifestPath);
  if (!xml) return new Set<string>();
  const blocks = Array.from(xml.matchAll(/<types>[\s\S]*?<\/types>/g)).map((m) => m[0]);
  const apexBlocks = blocks.filter((block) => /<name>\s*ApexClass\s*<\/name>/i.test(block));
  const members = new Set<string>();
  for (const block of apexBlocks) {
    for (const match of block.matchAll(/<members>\s*([^<]+)\s*<\/members>/g)) {
      const name = match[1].trim();
      if (name) members.add(name);
    }
  }
  return members;
}

async function buildTestMap(files: string[]): Promise<Map<string, { name: string; path: string; src: string }>> {
  const map = new Map<string, { name: string; path: string; src: string }>();
  if (!files.length) return map;
  const limit = Math.min(READ_CONCURRENCY, Math.max(1, files.length));
  let index = 0;
  const workers = Array.from({ length: limit }, async () => {
    while (true) {
      const current = index++;
      if (current >= files.length) break;
      const file = files[current];
      const src = await readFileSafe(file);
      if (!isApexTestClass(src, file)) continue;
      const name = detectApexClassName(src) || basename(file, ".cls");
      if (!name) continue;
      map.set(name, { name, path: file, src });
    }
  });
  await Promise.all(workers);
  return map;
}

export async function computeImpactedApexTests(opts: {
  repoDir: string;
  manifestPath?: string;
  fromRef?: string;
  toRef?: string;
  searchRoots?: string[];
  maxFiles?: number;
}): Promise<{ tests: string[]; details: ApexImpactDetails }> {
  const repoDir = resolve(opts.repoDir);
  const cfg = resolveProject(repoDir);
  const toRef = opts.toRef || "HEAD";
  const maxFiles = opts.maxFiles ?? DEFAULT_MAX_FILES;
  const manifestAbs = opts.manifestPath ? resolve(repoDir, opts.manifestPath) : undefined;
  const manifestSig = manifestAbs ? await fileSignature(manifestAbs) : undefined;
  const searchRoots = opts.searchRoots && opts.searchRoots.length ? opts.searchRoots : cfg.searchRoots;
  const keyParts = [
    repoDir,
    manifestSig ? `manifest:${manifestSig}` : "",
    opts.fromRef ? `git:${opts.fromRef}:${toRef}` : "",
    (searchRoots || []).slice().sort().join(","),
    String(maxFiles),
  ];
  const cacheKey = keyParts.join("|");
  const cached = impactCache.get(cacheKey);
  if (cached) return cached;

  const changedClasses = new Set<string>();
  const changedTestClasses = new Set<string>();
  let mode: ApexImpactDetails["mode"] = "unknown";

  if (manifestAbs) {
    mode = "manifest";
    const members = await loadManifestClasses(manifestAbs);
    members.forEach((name) => changedClasses.add(name));
  } else if (opts.fromRef) {
    mode = "git";
    const result = await gatherGitChangedClasses(repoDir, opts.fromRef, toRef, searchRoots ?? []);
    result.changedClasses.forEach((c) => changedClasses.add(c));
    result.changedTestClasses.forEach((c) => changedTestClasses.add(c));
  }

  const clsFiles = await listFiles(repoDir, APEX_EXTS, maxFiles, searchRoots);
  const testMap = await buildTestMap(clsFiles);

  const referenced = new Set<string>();
  const changedNames = Array.from(changedClasses);
  if (changedNames.length) {
    const patterns = changedNames.map((name) => new RegExp(`\\b${name}\\b`, "i"));
    for (const { name, src } of testMap.values()) {
      if (patterns.some((regex) => regex.test(src))) referenced.add(name);
    }
  }

  const heuristic = new Set<string>();
  for (const name of changedClasses) {
    for (const guess of deriveLikelyTestNames(name)) {
      for (const candidate of testMap.keys()) {
        if (candidate.toLowerCase() === guess.toLowerCase()) heuristic.add(candidate);
      }
    }
  }

  const combined = new Set<string>();
  for (const name of changedTestClasses) combined.add(name);
  for (const name of referenced) combined.add(name);
  for (const name of heuristic) combined.add(name);

  const tests = Array.from(combined).sort((a, b) => a.localeCompare(b));
  const details: ApexImpactDetails = {
    mode,
    changedClasses: Array.from(changedClasses),
    changedTestClasses: Array.from(changedTestClasses),
    viaReference: Array.from(referenced),
    viaHeuristic: Array.from(heuristic),
    totalTestFiles: testMap.size,
  };

  const value = { tests, details };
  impactCache.set(cacheKey, value);
  return value;
}
