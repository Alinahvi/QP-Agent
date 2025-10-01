
// C:\Users\<USER>\MCP\src\server.ts
// -----------------------------------------------------------------------------
// MCP server for Windows: Codex + Gemini "exec" planners, with hardened npm
// execution (no spawn EINVAL), writer/reader utilities, and quality gates.
// Design: let model CLIs PLAN; let MCP EXECUTE (writes/tests).
// -----------------------------------------------------------------------------

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
import { promises as fs } from "node:fs";
import { existsSync } from "node:fs";
import { join, dirname, resolve, sep, extname, basename } from "node:path";
import { runCommand, formatCommand } from "./utils/process.js";
import type { CommandResult } from "./utils/process.js";
import { resolveNpmCmd, codexAbs, npxAbs, resolveGeminiCmd, gitCandidates, sfCandidates } from "./utils/cliPaths.js";
import { computeImpactedApexTests } from "./utils/apexImpact.js";
import type { ApexImpactDetails } from "./utils/apexImpact.js";
import { resolveProject } from "./utils/projectResolver.js";
const VERSION = "1.2.0-deploy-safe";

// ------------------------------- helpers -------------------------------------

const DEFAULT_TIMEOUT_SEC = 1800;

interface CommandRun {
  result: CommandResult;
  summary: string;
}

function summarizeResult(cmd: string, args: string[], res: CommandResult): string {
  const parts = [
    `cmdline: ${formatCommand(cmd, args)}`,
    `exit ${res.code}${res.timedOut ? " (timeout)" : ""}`,
  ];
  if (res.error) parts.push(`error: ${res.error}`);
  parts.push("--- stdout ---", res.stdout);
  parts.push("--- stderr ---", res.stderr);
  return parts.join("\n");
}

async function runToolCommand(cmd: string, args: string[], opts: { cwd: string; timeoutSec?: number; input?: string; env?: NodeJS.ProcessEnv; }): Promise<CommandRun> {
  const { cwd, timeoutSec = DEFAULT_TIMEOUT_SEC, input, env } = opts;
  const result = await runCommand(cmd, args, { cwd, timeoutMs: timeoutSec * 1000, input, env });
  return { result, summary: summarizeResult(cmd, args, result) };
}

function parseJsonSafe<T>(input: string): T | null {
  if (!input) return null;
  try {
    return JSON.parse(input) as T;
  } catch {
    return null;
  }
}

function buildCommandResult(code: number, stdout = "", stderr = "", error?: string): CommandResult {
  const base: CommandResult = { code, stdout, stderr, durationMs: 0, timedOut: false };
  if (error !== undefined) {
    base.error = error;
  }
  return base;
}

interface SfExecution {
  ok: boolean;
  result: CommandResult;
  attempts: string[];
}

async function execSf(
  args: string[],
  opts: { cwd: string; timeoutSec?: number; input?: string; env?: NodeJS.ProcessEnv }
): Promise<SfExecution> {
  const { cwd, timeoutSec = DEFAULT_TIMEOUT_SEC, input, env } = opts;
  const attempts: string[] = [];
  let last: CommandResult | null = null;
  for (const bin of sfCandidates()) {
    const run = await runToolCommand(bin, args, { cwd, timeoutSec, input, env });
    attempts.push(run.summary);
    last = run.result;
    if (run.result.code === 0) {
      return { ok: true, result: run.result, attempts };
    }
  }
  return {
    ok: false,
    result: last ?? buildCommandResult(-1, "", "", "Failed to execute Salesforce CLI. No candidates succeeded."),
    attempts,
  };
}

type ResolvedProject = ReturnType<typeof resolveProject>;

type ApexTestSpec =
  | { kind: "tests"; items: string[]; reason: "impacted" | "allowlist" }
  | { kind: "suites"; items: string[]; reason: "suiteFallback" }
  | { kind: "none"; items: []; reason: "none" };

interface RepoScopedApexResult {
  ok: boolean;
  org: string;
  spec: ApexTestSpec;
  details: ApexImpactDetails;
  attempts: string[];
  runResult: CommandResult;
  artifactsDir: { relative: string; absolute: string };
  testRunId?: string;
  message?: string;
  raw?: unknown;
}

function determineApexTestSpec(impact: string[], cfg: ResolvedProject): ApexTestSpec {
  if (impact.length > 0) {
    return { kind: "tests", items: impact, reason: "impacted" };
  }
  if (cfg.apex.suiteNames.length > 0) {
    return { kind: "suites", items: cfg.apex.suiteNames, reason: "suiteFallback" };
  }
  if (cfg.apex.allowlist.length > 0) {
    return { kind: "tests", items: cfg.apex.allowlist, reason: "allowlist" };
  }
  return { kind: "none", items: [], reason: "none" };
}

async function runRepoScopedApexTests(
  repoDir: string,
  options: {
    waitSeconds?: number;
    orgOverride?: string;
    impact?: { tests: string[]; details: ApexImpactDetails };
  } = {}
): Promise<RepoScopedApexResult> {
  const cfg = resolveProject(repoDir);
  const org = options.orgOverride ?? cfg.defaultOrgAlias;
  const waitSeconds = options.waitSeconds ?? 1800;
  const impact =
    options.impact ??
    (await computeImpactedApexTests({
      repoDir,
      fromRef: cfg.apex.fromRef,
      toRef: "HEAD",
      searchRoots: cfg.searchRoots,
    }));
  const spec = determineApexTestSpec(impact.tests, cfg);
  const artifactRelative = join(cfg.artifactsDir, "apex");
  const artifactAbsolute = join(repoDir, artifactRelative);
  await fs.mkdir(artifactAbsolute, { recursive: true });

  if (spec.kind === "none") {
    return {
      ok: true,
      org,
      spec,
      details: impact.details,
      attempts: [],
      runResult: buildCommandResult(0),
      artifactsDir: { relative: artifactRelative, absolute: artifactAbsolute },
      message: "No impacted tests found and no fallback configured.",
      raw: null,
    };
  }

  const waitMinutes = Math.max(1, Math.ceil(waitSeconds / 60));
  const args = [
    "apex",
    "run",
    "test",
    "--target-org",
    org,
    "--wait",
    String(waitMinutes),
    "--test-level",
    "RunSpecifiedTests",
    "--json",
  ];

  if (spec.kind === "tests") {
    for (const item of spec.items) args.push("--class-names", item);
  } else if (spec.kind === "suites") {
    for (const item of spec.items) args.push("--suite-names", item);
  }

  const execResult = await execSf(args, {
    cwd: repoDir,
    timeoutSec: Math.max(waitMinutes * 60 + 60, DEFAULT_TIMEOUT_SEC),
  });

  const parsed =
    parseJsonSafe<any>(execResult.result.stdout) ??
    parseJsonSafe<any>(execResult.result.stderr);

  const testRunId =
    parsed?.result?.summary?.testRunId ??
    parsed?.result?.testRunId ??
    parsed?.summary?.testRunId ??
    parsed?.testRunId;

  if (testRunId) {
    await execSf(
      [
        "apex",
        "get",
        "test",
        "--test-run-id",
        testRunId,
        "--result-format",
        "junit",
        "--output-dir",
        artifactAbsolute,
      ],
      { cwd: repoDir, timeoutSec: DEFAULT_TIMEOUT_SEC }
    );
  }

  let message: string | undefined;
  if (spec.reason === "suiteFallback") {
    message = `No impacted tests detected; executed smoke suite(s): ${spec.items.join(", ")}`;
  } else if (spec.reason === "allowlist") {
    message = `No impacted tests detected; executed allowlist: ${spec.items.join(", ")}`;
  }

  return {
    ok: execResult.result.code === 0,
    org,
    spec,
    details: impact.details,
    attempts: execResult.attempts,
    runResult: execResult.result,
    artifactsDir: { relative: artifactRelative, absolute: artifactAbsolute },
    testRunId,
    message,
    raw: parsed ?? undefined,
  };
}


function ensureAgentConfig(cfg: ResolvedProject): void {
  if (!cfg.agent.enabled) {
    throw new Error("Agent automation is disabled for this project (.mcp.project.json agent.enabled=false).");
  }
  if (!cfg.agent.definitionApiName) {
    throw new Error("Missing agent.definitionApiName in .mcp.project.json");
  }
  if (!cfg.agent.specPath) {
    throw new Error("Missing agent.specPath in .mcp.project.json");
  }
}

async function runAgentTestSuite(
  repoDir: string,
  cfg: ResolvedProject,
  org: string,
  waitMinutes = 15
): Promise<{ ok: boolean; attempts: string[]; runResult: CommandResult; artifactsDir: { relative: string; absolute: string } }> {
  ensureAgentConfig(cfg);
  const artifactRelative = cfg.agent.artifactDir || join(cfg.artifactsDir, "agent");
  const artifactAbsolute = join(repoDir, artifactRelative);
  await fs.mkdir(artifactAbsolute, { recursive: true });

  const args = [
    "agent",
    "test",
    "run",
    "--api-name",
    cfg.agent.definitionApiName,
    "--wait",
    String(waitMinutes),
    "--result-format",
    cfg.agent.resultFormat ?? "junit",
    "--output-dir",
    artifactAbsolute,
    "--target-org",
    org,
  ];

  const execResult = await execSf(args, {
    cwd: repoDir,
    timeoutSec: Math.max(waitMinutes * 60 + 60, DEFAULT_TIMEOUT_SEC),
  });

  return {
    ok: execResult.result.code === 0,
    attempts: execResult.attempts,
    runResult: execResult.result,
    artifactsDir: { relative: artifactRelative, absolute: artifactAbsolute },
  };
}


async function trySfDeploy(
  repoDir: string,
  opts: {
    org: string;
    sourceDirs?: string[];
    manifestPath?: string;
    metadata?: string[];
    testLevel?: "NoTestRun" | "RunSpecifiedTests" | "RunLocalTests";
    tests?: string[];
    checkOnly?: boolean;
    ignoreConflicts?: boolean;
    waitSeconds?: number;
    json?: boolean;
  }
): Promise<{ code:number; out:string; err:string; attempts:string[] }> {
  const bins = sfCandidates();
  const attempts: string[] = [];
  const { org, sourceDirs, manifestPath, metadata, testLevel, tests, checkOnly, ignoreConflicts, waitSeconds, json } = opts;

  const buildFlags = (kebab: boolean): string[] => {
    const flags: string[] = ["--target-org", org];
    if (waitSeconds && waitSeconds > 0) flags.push("--wait", String(waitSeconds));
    if (ignoreConflicts) flags.push("--ignore-conflicts");
    if (json) flags.push("--json");
    if (sourceDirs && sourceDirs.length) flags.push("--source-dir", sourceDirs.join(","));
    if (manifestPath) flags.push("--manifest", manifestPath);
    if (metadata && metadata.length) flags.push("--metadata", metadata.join(","));
    if (testLevel) flags.push(kebab ? "--test-level" : "--testlevel", testLevel);
    if (tests && tests.length) flags.push("--tests", tests.join(","));
    return flags;
  };

  type Variant = { name: string; useKebab: boolean; buildArgs: (flags: string[]) => string[] };
  const variants: Variant[] = [
    {
      name: "sf project deploy start",
      useKebab: true,
      buildArgs: (flags) => {
        const args = ["project", "deploy", "start", ...flags];
        if (checkOnly) args.push("--dry-run");
        return args;
      },
    },
    {
      name: "sf force source deploy",
      useKebab: false,
      buildArgs: (flags) => {
        const args = ["force", "source", "deploy", ...flags];
        if (checkOnly) args.push("--checkonly");
        return args;
      },
    },
  ];

  let last: CommandResult | null = null;
  const timeoutSec = Math.max(300, (waitSeconds ?? DEFAULT_TIMEOUT_SEC) + 120);

  for (const bin of bins) {
    for (const variant of variants) {
      const args = variant.buildArgs(buildFlags(variant.useKebab));
      const { result, summary } = await runToolCommand(bin, args, { cwd: repoDir, timeoutSec });
      attempts.push(`[${variant.name}] ${summary}`);
      last = result;
      if (result.code === 0) {
        return { code: 0, out: result.stdout, err: result.stderr, attempts };
      }
    }
  }

  return {
    code: last?.code ?? 1,
    out: last?.stdout ?? "",
    err: last?.stderr ?? "",
    attempts,
  };
}


// ------------------------------- server --------------------------------------

const server = new McpServer({ name: "sf-codex", version: VERSION });

server.registerTool(
  "ping",
  { title:"Ping", description:"health check", inputSchema:{} },
  async () => ({ content:[{ type:"text", text:`pong ${VERSION}` }] })
);

// --- Codex exec (plan only; no policy flags injected) ------------------------
server.registerTool(
  "codex_exec",
  {
    title: "Codex exec (plan)",
    description: "Run `codex exec <PROMPT>` inside repoDir (no flags injected)",
    inputSchema: { repoDir: z.string(), task: z.string(), maxSeconds: z.number().int().positive().default(1800) }
  },
  async ({ repoDir, task, maxSeconds }) => {
    const attempts: string[] = [];
    const timeoutSec = maxSeconds ?? DEFAULT_TIMEOUT_SEC;
    const run = async (cmd: string, args: string[]) => {
      const { result, summary } = await runToolCommand(cmd, args, { cwd: repoDir, timeoutSec });
      attempts.push(summary);
      return result;
    };

    if (process.platform === "win32") {
      const abs = codexAbs();
      if (existsSync(abs)) {
        await run(abs, ["exec", task]);
        return { content:[{ type:"text", text: attempts.join("\n\n") }] };
      }
      const nx = npxAbs();
      if (existsSync(nx)) {
        await run(nx, ["-y", "codex", "exec", task]);
        return { content:[{ type:"text", text: attempts.join("\n\n") }] };
      }
    }

    await run("codex", ["exec", task]);
    return { content:[{ type:"text", text: attempts.join("\n\n") }] };
  }
);

// --- Gemini exec (plan) ------------------------------------------------------
server.registerTool(
  "gemini_exec",
  {
    title: "Gemini exec (plan)",
    description: "Run Gemini CLI in repoDir using -p/--prompt (non-interactive).",
    inputSchema: {
      repoDir: z.string(),
      task: z.string(),
      maxSeconds: z.number().int().positive().max(7200).default(1800),
      model: z.string().optional(),
      reasoning: z.string().optional(),
      extraArgs: z.array(z.string()).optional()
    }
  },
  async ({ repoDir, task, maxSeconds, model, reasoning, extraArgs }) => {
    const bins = resolveGeminiCmd();
    const attempts: string[] = [];
    const timeoutSec = maxSeconds ?? DEFAULT_TIMEOUT_SEC;

    const flagParts: string[] = [];
    if (model) flagParts.push("--model", model);
    if (extraArgs && Array.isArray(extraArgs)) flagParts.push(...extraArgs);

    for (const bin of bins) {
      const args = [...flagParts, "-p", task];
      const { result, summary } = await runToolCommand(bin, args, { cwd: repoDir, timeoutSec });
      attempts.push(summary);
      if (result.code === 0) {
        return { content:[{ type:"text", text: summary }] };
      }
    }

    const message = `Failed to launch or run Gemini CLI. Tried ${bins.length} candidate(s).\n\n${attempts.join("\n\n")}`;
    return { content:[{ type:"text", text: message }] };
  }
);

// --- Readers/Writers ----------------------------------------------------------
server.registerTool(
  "read_dir",
  {
    title: "Read directory entries",
    description: "List files/dirs inside a relative directory",
    inputSchema: { repoDir: z.string(), relPath: z.string().default("."), depth: z.number().int().min(0).max(2).default(0) }
  },
  async ({ repoDir, relPath, depth }) => {
    const root = join(repoDir, relPath);
    async function list(path: string, d: number): Promise<any> {
      const entries = await fs.readdir(path, { withFileTypes: true });
      const items = await Promise.all(entries.map(async e => {
        const p = join(path, e.name);
        const rec:any = { name: e.name, dir: e.isDirectory() };
        if (d > 0 && e.isDirectory()) rec.children = await list(p, d-1);
        return rec;
      }));
      return items;
    }
    const items = await list(root, depth);
    return { content:[{ type:"text", text: JSON.stringify({ path: root, items }, null, 2) }] };
  }
);

server.registerTool(
  "read_file",
  {
    title: "Read file (utf-8 head/tail)",
    description: "Read up to N bytes from head and tail of a file",
    inputSchema: { repoDir: z.string(), relPath: z.string(), head: z.number().int().default(4000), tail: z.number().int().default(4000) }
  },
  async ({ repoDir, relPath, head, tail }) => {
    const file = join(repoDir, relPath);
    const stat = await fs.stat(file);
    const size = stat.size;
    const readHead = Math.min(head, size);
    const readTail = tail > 0 ? Math.min(tail, Math.max(0, size - readHead)) : 0;

    let headStr = "";
    let tailStr = "";
    if (size <= readHead + readTail + 8192) {
      const buf = await fs.readFile(file);
      const text = buf.toString("utf8");
      headStr = text.slice(0, head);
      tailStr = tail > 0 ? text.slice(Math.max(0, text.length - tail)) : "";
    } else {
      const handle = await fs.open(file, "r");
      try {
        if (readHead > 0) {
          const buffer = Buffer.alloc(readHead);
          await handle.read(buffer, 0, readHead, 0);
          headStr = buffer.toString("utf8");
        }
        if (readTail > 0) {
          const buffer = Buffer.alloc(readTail);
          await handle.read(buffer, 0, readTail, size - readTail);
          tailStr = buffer.toString("utf8");
        }
      } finally {
        await handle.close();
      }
    }

    const payload = { file, size, head: headStr, tail: tailStr };
    return { content:[{ type:"text", text: JSON.stringify(payload, null, 2) }] };
  }
);

server.registerTool(
  "mkdirp",
  {
    title: "Make directory (recursive)",
    description: "Create a directory inside repoDir",
    inputSchema: { repoDir: z.string(), relPath: z.string() }
  },
  async ({ repoDir, relPath }) => {
    const dir = join(repoDir, relPath);
    await fs.mkdir(dir, { recursive: true });
    return { content:[{ type:"text", text:`ok: ${dir}` }] };
  }
);

server.registerTool(
  "write_file",
  {
    title: "Write file (UTF-8)",
    description: "Create/overwrite a file inside repoDir",
    inputSchema: { repoDir: z.string(), relPath: z.string(), content: z.string(), noNewline: z.boolean().default(false) }
  },
  async ({ repoDir, relPath, content, noNewline }) => {
    const file = join(repoDir, relPath);
    await fs.mkdir(dirname(file), { recursive: true });
    await fs.writeFile(file, noNewline ? content : content + "\n", "utf8");
    return { content:[{ type:"text", text:`ok: ${file}` }] };
  }
);

// --- Apply unified diff via git apply on stdin --------------------------------
server.registerTool(
  "apply_diff",
  {
    title: "Apply unified diff",
    description: "Applies a unified diff using `git apply -p0 --whitespace=fix -`",
    inputSchema: { repoDir: z.string(), diff: z.string(), maxSeconds: z.number().int().default(180) }
  },
  async ({ repoDir, diff, maxSeconds }) => {
    const attempts: string[] = [];
    let last: CommandResult | null = null;
    for (const git of gitCandidates()) {
      const run = await runToolCommand(git, ["apply", "-p0", "--whitespace=fix", "-"], { cwd: repoDir, timeoutSec: maxSeconds, input: diff });
      attempts.push(run.summary);
      last = run.result;
      if (run.result.code !== -1) break;
    }
    const text = attempts.length ? attempts.join("\n\n") : "no git candidates executed";
    return { content:[{ type:"text", text }] };
  }
);

// --- NPM-based tools (Windows-safe: absolute npm.cmd via single cmdline) ------
server.registerTool(
  "jest_mcp",
  {
    title: "Run LWC Jest (MCP script)",
    description: "npm run test:unit:mcp",
    inputSchema: { repoDir: z.string(), maxSeconds: z.number().int().default(1800) }
  },
  async ({ repoDir, maxSeconds }) => {
    const npm = resolveNpmCmd();
    const { summary } = await runToolCommand(npm, ["run", "test:unit:mcp"], { cwd: repoDir, timeoutSec: maxSeconds });
    return { content:[{ type:"text", text: summary }] };
  }
);

server.registerTool(
  "apex_mcp",
  {
    title: "Run Apex tests (MCP script)",
    description: "npm run test:apex:mcp",
    inputSchema: { repoDir: z.string(), maxSeconds: z.number().int().default(3600) }
  },
  async ({ repoDir, maxSeconds }) => {
    // Disabled to prevent accidental execution of all local tests in the org.
    return { content:[{ type:"text", text:"Disabled: use 'apex_run_tests' and provide explicit test classes or suites." }], isError: true };
  }
);

server.registerTool(
  "analyze_mcp",
  {
    title: "Salesforce Code Analyzer (MCP script)",
    description: "npm run analyze:mcp",
    inputSchema: { repoDir: z.string(), maxSeconds: z.number().int().default(1800) }
  },
  async ({ repoDir, maxSeconds }) => {
    const npm = resolveNpmCmd();
    const { summary } = await runToolCommand(npm, ["run", "analyze:mcp"], { cwd: repoDir, timeoutSec: maxSeconds });
    return { content:[{ type:"text", text: summary }] };
  }
);

// --- Safe Salesforce deploy (never default to RunLocalTests) -----------------
server.registerTool(
  "agent:spec",
  {
    title: "Generate Agentforce spec",
    description: "Runs `sf agent generate test-spec` using project configuration",
    inputSchema: {
      repoDir: z.string(),
      org: z.string().optional()
    }
  },
  async ({ repoDir, org }) => {
    try {
      const cfg = resolveProject(repoDir);
      ensureAgentConfig(cfg);
      const targetOrg = org ?? cfg.defaultOrgAlias;
      const specRelative = cfg.agent.specPath;
      const specAbsolute = join(repoDir, specRelative);
      await fs.mkdir(dirname(specAbsolute), { recursive: true });

      const args = ["agent", "generate", "test-spec", "--output-file", specAbsolute];
      if (targetOrg) {
        args.push("--target-org", targetOrg);
      }

      const execResult = await execSf(args, { cwd: repoDir, timeoutSec: DEFAULT_TIMEOUT_SEC });
      const payload = {
        org: targetOrg,
        specPath: specRelative,
        exitCode: execResult.result.code,
        attempts: execResult.attempts,
        stdoutTail: execResult.result.stdout.slice(-1500),
        stderrTail: execResult.result.stderr.slice(-1500),
      };
      return {
        content: [{ type: "text", text: JSON.stringify(payload, null, 2) }],
        isError: execResult.result.code !== 0,
      };
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      return { content: [{ type: "text", text: message }], isError: true };
    }
  }
);

server.registerTool(
  "agent:create",
  {
    title: "Create Agentforce test definition",
    description: "Runs `sf agent test create` using the generated spec path",
    inputSchema: {
      repoDir: z.string(),
      org: z.string().optional()
    }
  },
  async ({ repoDir, org }) => {
    try {
      const cfg = resolveProject(repoDir);
      ensureAgentConfig(cfg);
      const targetOrg = org ?? cfg.defaultOrgAlias;
      const specAbsolute = join(repoDir, cfg.agent.specPath);

      const args = [
        "agent",
        "test",
        "create",
        "--spec",
        specAbsolute,
        "--api-name",
        cfg.agent.definitionApiName,
        "--target-org",
        targetOrg,
      ];

      const execResult = await execSf(args, { cwd: repoDir, timeoutSec: DEFAULT_TIMEOUT_SEC });
      const payload = {
        org: targetOrg,
        specPath: cfg.agent.specPath,
        definitionApiName: cfg.agent.definitionApiName,
        exitCode: execResult.result.code,
        attempts: execResult.attempts,
        stdoutTail: execResult.result.stdout.slice(-1500),
        stderrTail: execResult.result.stderr.slice(-1500),
      };
      return {
        content: [{ type: "text", text: JSON.stringify(payload, null, 2) }],
        isError: execResult.result.code !== 0,
      };
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      return { content: [{ type: "text", text: message }], isError: true };
    }
  }
);

server.registerTool(
  "tests:agent",
  {
    title: "Run Agentforce tests",
    description: "Runs the configured agent test definition and stores artifacts",
    inputSchema: {
      repoDir: z.string(),
      org: z.string().optional(),
      waitMinutes: z.number().int().positive().max(240).default(15)
    }
  },
  async ({ repoDir, org, waitMinutes }) => {
    try {
      const cfg = resolveProject(repoDir);
      const targetOrg = org ?? cfg.defaultOrgAlias;
      const result = await runAgentTestSuite(repoDir, cfg, targetOrg, waitMinutes);
      const payload = {
        org: targetOrg,
        definitionApiName: cfg.agent.definitionApiName,
        waitMinutes,
        exitCode: result.runResult.code,
        attempts: result.attempts,
        stdoutTail: result.runResult.stdout.slice(-1500),
        stderrTail: result.runResult.stderr.slice(-1500),
        artifactsDir: result.artifactsDir.relative,
      };
      return {
        content: [{ type: "text", text: JSON.stringify(payload, null, 2) }],
        isError: !result.ok,
      };
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      return { content: [{ type: "text", text: message }], isError: true };
    }
  }
);


server.registerTool(
  "release:branch",
  {
    title: "Release branch pipeline",
    description: "Deploys with NoTestRun, runs scoped Apex tests, then Agent tests (if enabled).",
    inputSchema: {
      repoDir: z.string(),
      org: z.string().optional(),
      waitSeconds: z.number().int().positive().max(14400).default(1800),
      checkOnly: z.boolean().default(false),
      skipAgent: z.boolean().default(false)
    }
  },
  async ({ repoDir, org, waitSeconds, checkOnly, skipAgent }) => {
    const cfg = resolveProject(repoDir);
    const targetOrg = org ?? cfg.defaultOrgAlias;

    const deploySourceDirs = cfg.deploy.sourceDirs && cfg.deploy.sourceDirs.length ? cfg.deploy.sourceDirs : undefined;
    const deployManifest = cfg.deploy.manifest;
    if (!deploySourceDirs && !deployManifest) {
      return {
        content: [{
          type: "text",
          text: "Configure deploy.manifest or deploy.sourceDirs in .mcp.project.json to use release:branch.",
        }],
        isError: true,
      };
    }

    const deployResult = await trySfDeploy(repoDir, {
      org: targetOrg,
      sourceDirs: deploySourceDirs,
      manifestPath: deployManifest,
      testLevel: "NoTestRun",
      ignoreConflicts: true,
      waitSeconds,
      json: true,
      checkOnly,
    });
    const deployOk = deployResult.code === 0;

    const apexResult = await runRepoScopedApexTests(repoDir, { waitSeconds, orgOverride: targetOrg });

    let agentPayload: any = { skipped: true };
    let agentOk = true;
    if (cfg.agent.enabled && !skipAgent) {
      try {
        const agentResult = await runAgentTestSuite(repoDir, cfg, targetOrg);
        agentPayload = {
          ok: agentResult.ok,
          definitionApiName: cfg.agent.definitionApiName,
          exitCode: agentResult.runResult.code,
          attempts: agentResult.attempts,
          stdoutTail: agentResult.runResult.stdout.slice(-1500),
          stderrTail: agentResult.runResult.stderr.slice(-1500),
          artifactsDir: agentResult.artifactsDir.relative,
        };
        agentOk = agentResult.ok;
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        agentPayload = { ok: false, error: message };
        agentOk = false;
      }
    } else if (skipAgent || !cfg.agent.enabled) {
      agentPayload = {
        ok: true,
        skipped: true,
      };
    }

    const payload = {
      org: targetOrg,
      deploy: {
        ok: deployOk,
        exitCode: deployResult.code,
        attempts: deployResult.attempts,
        stdoutTail: deployResult.out.slice(-1500),
        stderrTail: deployResult.err.slice(-1500),
      },
      apex: {
        ok: apexResult.ok,
        spec: apexResult.spec,
        message: apexResult.message ?? null,
        exitCode: apexResult.runResult.code,
        attempts: apexResult.attempts,
        testRunId: apexResult.testRunId ?? null,
        artifactsDir: apexResult.artifactsDir.relative,
        stdoutTail: apexResult.runResult.stdout.slice(-1500),
        stderrTail: apexResult.runResult.stderr.slice(-1500),
      },
      agent: agentPayload,
    };

    const isError = !deployOk || !apexResult.ok || !agentOk;
    return {
      content: [{ type: "text", text: JSON.stringify(payload, null, 2) }],
      isError,
    };
  }
);


server.registerTool(
  "sf_deploy",
  {
    title: "Salesforce deploy (safe defaults)",
    description: "Deploys metadata/source with default test level NoTestRun. Explicitly opt-in to specified tests; RunLocalTests is blocked unless allowRunLocalTests is true.",
    inputSchema: {
      repoDir: z.string(),
      org: z.string().optional(),
      sourceDirs: z.array(z.string()).optional(),
      manifestPath: z.string().optional(),
      metadata: z.array(z.string()).optional(),
      testLevel: z.enum(["NoTestRun", "RunSpecifiedTests", "RunLocalTests"]).optional(),
      tests: z.array(z.string()).optional(),
      checkOnly: z.boolean().default(false),
      ignoreConflicts: z.boolean().default(true),
      waitSeconds: z.number().int().positive().max(14400).default(1800),
      json: z.boolean().default(true),
      allowRunLocalTests: z.boolean().default(false)
    }
  },
  async ({ repoDir, org, sourceDirs, manifestPath, metadata, testLevel, tests, checkOnly, ignoreConflicts, waitSeconds, json, allowRunLocalTests }) => {
    const cfg = resolveProject(repoDir);
    const targetOrg = org ?? cfg.defaultOrgAlias;
    // Validate inputs
    if (!sourceDirs && !manifestPath && !metadata) {
      return { content:[{ type:"text", text:"Provide one of 'sourceDirs', 'manifestPath', or 'metadata'" }], isError: true };
    }
    // Default to NoTestRun when not specified
    let level = testLevel || "NoTestRun";
    if (level === "RunLocalTests" && !allowRunLocalTests) {
      return { content:[{ type:"text", text:"Blocked: 'RunLocalTests' would execute all local tests. Set 'allowRunLocalTests' to true to override (not recommended)." }], isError: true };
    }
    if (tests && tests.length && level !== "RunSpecifiedTests") {
      level = "RunSpecifiedTests"; // auto-escalate when tests provided
    }
    if (level === "RunSpecifiedTests" && (!tests || tests.length === 0)) {
      return { content:[{ type:"text", text:"When 'testLevel' is 'RunSpecifiedTests', you must provide 'tests'." }], isError: true };
    }

    const res = await trySfDeploy(repoDir, { org: targetOrg, sourceDirs, manifestPath, metadata, testLevel: level, tests, checkOnly, ignoreConflicts, waitSeconds, json });
    const summary = `exit ${res.code}\n${res.attempts.join("\n\n")}`;
    return { content:[{ type:"text", text: summary }], isError: res.code !== 0 };
  }
);

// --- Run only specified Apex tests -------------------------------------------
server.registerTool(
  "apex_run_tests",
  {
    title: "Run specified Apex tests",
    description: "Runs only the provided Apex tests or suites against a target org using Salesforce CLI",
    inputSchema: {
      repoDir: z.string(),
      org: z.string().optional(),
      tests: z.array(z.string()).optional(),
      suites: z.array(z.string()).optional(),
      waitSeconds: z.number().int().positive().max(14400).default(1800),
      json: z.boolean().default(true)
    }
  },
  async ({ repoDir, org, tests, suites, waitSeconds, json }) => {
    const cfg = resolveProject(repoDir);
    const targetOrg = org ?? cfg.defaultOrgAlias;
    const testList = tests?.slice() ?? [];
    const suiteList = suites?.slice() ?? [];

    if (testList.length && suiteList.length) {
      return {
        content: [{ type: "text", text: "Provide either tests or suites, not both." }],
        isError: true,
      };
    }

    if (testList.length === 0 && suiteList.length === 0) {
      return {
        content: [{
          type: "text",
          text: "No tests or suites provided. Refusing to run all local tests. Supply \"tests\" or \"suites\".",
        }],
        isError: true,
      };
    }

    const waitMinutes = Math.max(1, Math.ceil(waitSeconds / 60));
    const args = [
      "apex",
      "run",
      "test",
      "--target-org",
      targetOrg,
      "--wait",
      String(waitMinutes),
      "--test-level",
      "RunSpecifiedTests",
    ];

    if (json) args.push("--json");

    if (testList.length) {
      for (const entry of testList) {
        args.push("--tests", entry);
      }
    }

    if (suiteList.length) {
      for (const entry of suiteList) {
        args.push("--suite-names", entry);
      }
    }

    const artifactRelative = join(cfg.artifactsDir, "apex");
    const artifactAbsolute = join(repoDir, artifactRelative);
    await fs.mkdir(artifactAbsolute, { recursive: true });

    const execResult = await execSf(args, {
      cwd: repoDir,
      timeoutSec: Math.max(waitMinutes * 60 + 60, DEFAULT_TIMEOUT_SEC),
    });

    const parsed =
      parseJsonSafe<any>(execResult.result.stdout) ??
      parseJsonSafe<any>(execResult.result.stderr);

    const testRunId =
      parsed?.result?.summary?.testRunId ??
      parsed?.result?.testRunId ??
      parsed?.summary?.testRunId ??
      parsed?.testRunId;

    if (testRunId) {
      await execSf(
        [
          "apex",
          "get",
          "test",
          "--test-run-id",
          testRunId,
          "--result-format",
          "junit",
          "--output-dir",
          artifactAbsolute,
        ],
        { cwd: repoDir, timeoutSec: DEFAULT_TIMEOUT_SEC }
      );
    }

    const payload = {
      org: targetOrg,
      tests: testList,
      suites: suiteList,
      waitMinutes,
      exitCode: execResult.result.code,
      attempts: execResult.attempts,
      stdoutTail: execResult.result.stdout.slice(-1500),
      stderrTail: execResult.result.stderr.slice(-1500),
      testRunId: testRunId ?? null,
      artifactsDir: artifactRelative,
    };

    return {
      content: [{ type: "text", text: JSON.stringify(payload, null, 2) }],
      isError: execResult.result.code !== 0,
    };
  }
);

// --- Quality gate: Jest → Apex → Analyzer ------------------------------------
server.registerTool(
  "quality_gate",
  {
    title: "Quality Gate",
    description: "Runs Jest  Apex  Analyzer and summarizes artifacts",
    inputSchema: {
      repoDir: z.string(),
      stopOnFail: z.boolean().default(true),
      org: z.string().optional(),
      apexTests: z.array(z.string()).optional(),
      apexSuites: z.array(z.string()).optional()
    }
  },
  async ({ repoDir, stopOnFail, org, apexTests, apexSuites }) => {
    const npm = resolveNpmCmd();
    const results: any[] = [];
    let pass = true;

    const artifactRecords = (paths: string[]) => paths.map(path => ({ path, exists: existsSync(path) }));

    const runNpmStep = async (step: string, args: string[], timeoutSec: number, artifacts: string[]) => {
      const { result } = await runToolCommand(npm, args, { cwd: repoDir, timeoutSec });
      const ok = result.code === 0;
      pass = pass && ok;
      results.push({
        step,
        exitCode: result.code ?? -1,
        outTail: result.stdout.slice(-1500),
        errTail: result.stderr.slice(-1500),
        artifacts: artifactRecords(artifacts),
      });
      return ok;
    };

    const jestOk = await runNpmStep("jest", ["run", "test:unit:mcp"], 2400, [join(repoDir, ".artifacts", "jest-junit.xml")]);
    if (!jestOk && stopOnFail) return { content:[{ type:"text", text: JSON.stringify({ pass, results }, null, 2) }] };

    if (org && ((apexTests && apexTests.length) || (apexSuites && apexSuites.length))) {
      const bins = sfCandidates();
      const parts: string[] = [
        "apex", "run", "test",
        "--target-org", org,
        "--wait", String(2400),
        "--json"
      ];
      if (apexTests && apexTests.length) parts.push("--tests", apexTests.join(","));
      if (apexSuites && apexSuites.length) parts.push("--suites", apexSuites.join(","));
      const attempts: string[] = [];
      let last: CommandResult | null = null;
      for (const bin of bins) {
        const run = await runToolCommand(bin, parts, { cwd: repoDir, timeoutSec: 2400 });
        attempts.push(run.summary);
        last = run.result;
        if (run.result.code === 0) break;
      }
      const ok = !!last && last.code === 0;
      pass = pass && ok;
      results.push({
        step: "apex",
        exitCode: last?.code ?? -1,
        outTail: (last?.stdout ?? "").slice(-1500),
        errTail: (last?.stderr ?? "").slice(-1500),
        attempts,
        artifacts: artifactRecords([join(repoDir, ".artifacts", "tests")]),
      });
      if (!ok && stopOnFail) return { content:[{ type:"text", text: JSON.stringify({ pass, results }, null, 2) }] };
    }

    await runNpmStep("anlz", ["run", "analyze:mcp"], 2400, [join(repoDir, ".artifacts", "code-analysis.json")]);

    return { content:[{ type:"text", text: JSON.stringify({ pass, results }, null, 2) }] };
  }
);

// --- Impacted Apex tests: compute list --------------------------------------
server.registerTool(
  "apex_impacted_tests",
  {
    title: "Compute impacted Apex tests",
    description: "Builds a list of impacted Apex test classes from a package.xml or git diff",
    inputSchema: {
      repoDir: z.string(),
      manifestPath: z.string().optional(),
      fromRef: z.string().optional(),
      toRef: z.string().optional(),
      searchRoots: z.array(z.string()).optional(),
      maxFiles: z.number().int().positive().default(4000)
    }
  },
  async ({ repoDir, manifestPath, fromRef, toRef, searchRoots, maxFiles }) => {
    if (!manifestPath && !fromRef) {
      return { content:[{ type:"text", text:"Provide either 'manifestPath' or 'fromRef' to compute impacted tests." }], isError: true };
    }
    const { tests, details } = await computeImpactedApexTests({ repoDir, manifestPath, fromRef, toRef, searchRoots, maxFiles });
    return { content:[{ type:"text", text: JSON.stringify({ tests, details }, null, 2) }] };
  }
);

// --- Impacted Apex tests: compute and run -----------------------------------
server.registerTool(
  "tests:apex",
  {
    title: "Run repo-scoped Apex tests",
    description: "Computes impacted Apex tests using project config, with smoke/allowlist fallback, and fetches JUnit artifacts.",
    inputSchema: {
      repoDir: z.string(),
      org: z.string().optional(),
      waitSeconds: z.number().int().positive().max(14400).default(1800)
    }
  },
  async ({ repoDir, org, waitSeconds }) => {
    try {
      const result = await runRepoScopedApexTests(repoDir, { waitSeconds, orgOverride: org });
      const payload = {
        org: result.org,
        spec: result.spec,
        details: result.details,
        attempts: result.attempts,
        exitCode: result.runResult.code,
        stdoutTail: result.runResult.stdout.slice(-1500),
        stderrTail: result.runResult.stderr.slice(-1500),
        testRunId: result.testRunId ?? null,
        artifactsDir: result.artifactsDir.relative,
        message: result.message ?? null,
      };
      return {
        content: [{ type: "text", text: JSON.stringify(payload, null, 2) }],
        isError: !result.ok,
      };
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      return { content: [{ type: "text", text: message }], isError: true };
    }
  }
);


server.registerTool(
  "apex_impacted_tests_run",
  {
    title: "Run impacted Apex tests",
    description: "Computes impacted tests (manifest or git diff) and runs them via Salesforce CLI",
    inputSchema: {
      repoDir: z.string(),
      org: z.string().optional(),
      manifestPath: z.string().optional(),
      fromRef: z.string().optional(),
      toRef: z.string().optional(),
      searchRoots: z.array(z.string()).optional(),
      waitSeconds: z.number().int().positive().max(14400).default(1800),
      json: z.boolean().default(true)
    }
  },
  async ({ repoDir, org, manifestPath, fromRef, toRef, searchRoots, waitSeconds, json }) => {
    if (!manifestPath && !fromRef) {
      return { content:[{ type:"text", text:"Provide either \"manifestPath\" or \"fromRef\" to compute impacted tests." }], isError: true };
    }

    const cfg = resolveProject(repoDir);
    const targetOrg = org ?? cfg.defaultOrgAlias;
    const roots = searchRoots && searchRoots.length ? searchRoots : cfg.searchRoots;
    const { tests, details } = await computeImpactedApexTests({ repoDir, manifestPath, fromRef, toRef, searchRoots: roots });

    if (!tests.length) {
      const payload = {
        message: "No impacted tests found; nothing to run.",
        details,
      };
      return { content:[{ type:"text", text: JSON.stringify(payload, null, 2) }] };
    }

    const waitMinutes = Math.max(1, Math.ceil(waitSeconds / 60));
    const args = [
      "apex",
      "run",
      "test",
      "--target-org",
      targetOrg,
      "--wait",
      String(waitMinutes),
      "--test-level",
      "RunSpecifiedTests",
    ];

    if (json) args.push("--json");

    for (const test of tests) {
      args.push("--class-names", test);
    }

    const artifactRelative = join(cfg.artifactsDir, "apex");
    const artifactAbsolute = join(repoDir, artifactRelative);
    await fs.mkdir(artifactAbsolute, { recursive: true });

    const execResult = await execSf(args, {
      cwd: repoDir,
      timeoutSec: Math.max(waitMinutes * 60 + 60, DEFAULT_TIMEOUT_SEC),
    });

    const parsed =
      parseJsonSafe<any>(execResult.result.stdout) ??
      parseJsonSafe<any>(execResult.result.stderr);

    const testRunId =
      parsed?.result?.summary?.testRunId ??
      parsed?.result?.testRunId ??
      parsed?.summary?.testRunId ??
      parsed?.testRunId;

    if (testRunId) {
      await execSf(
        [
          "apex",
          "get",
          "test",
          "--test-run-id",
          testRunId,
          "--result-format",
          "junit",
          "--output-dir",
          artifactAbsolute,
        ],
        { cwd: repoDir, timeoutSec: DEFAULT_TIMEOUT_SEC }
      );
    }

    const payload = {
      org: targetOrg,
      tests,
      details,
      attempts: execResult.attempts,
      exitCode: execResult.result.code,
      stdoutTail: execResult.result.stdout.slice(-1500),
      stderrTail: execResult.result.stderr.slice(-1500),
      testRunId: testRunId ?? null,
      artifactsDir: artifactRelative,
    };

    return {
      content: [{ type: "text", text: JSON.stringify(payload, null, 2) }],
      isError: execResult.result.code !== 0,
    };
  }
);

// --- Deploy and run impacted Apex tests (safe defaults) ---------------------
server.registerTool(
  "sf_deploy_impacted",
  {
    title: "Deploy with impacted tests",
    description: "Computes impacted Apex tests (from manifest or git diff) and deploys. Uses RunSpecifiedTests with impacted tests when found, otherwise defaults to NoTestRun.",
    inputSchema: {
      repoDir: z.string(),
      org: z.string().optional(),
      // Deploy inputs (one is required)
      deploySourceDirs: z.array(z.string()).optional(),
      deployManifestPath: z.string().optional(),
      deployMetadata: z.array(z.string()).optional(),
      // Impact calculation inputs (one of impactManifestPath or fromRef required)
      impactManifestPath: z.string().optional(),
      fromRef: z.string().optional(),
      toRef: z.string().optional(),
      searchRoots: z.array(z.string()).optional(),
      maxFiles: z.number().int().positive().default(4000),
      // Deploy behaviors
      checkOnly: z.boolean().default(false),
      ignoreConflicts: z.boolean().default(true),
      waitSeconds: z.number().int().positive().max(14400).default(1800),
      json: z.boolean().default(true),
      // Control behavior when no impacted tests
      deployWhenNoTests: z.boolean().default(true)
    }
  },
  async ({
    repoDir,
    org,
    deploySourceDirs,
    deployManifestPath,
    deployMetadata,
    impactManifestPath,
    fromRef,
    toRef,
    searchRoots,
    maxFiles,
    checkOnly,
    ignoreConflicts,
    waitSeconds,
    json,
    deployWhenNoTests
  }) => {
    const cfg = resolveProject(repoDir);
    const targetOrg = org ?? cfg.defaultOrgAlias;
    if (!deploySourceDirs && !deployManifestPath && !deployMetadata) {
      return { content:[{ type:"text", text:"Provide one of 'deploySourceDirs', 'deployManifestPath', or 'deployMetadata' for deployment." }], isError: true };
    }
    if (!impactManifestPath && !fromRef) {
      return { content:[{ type:"text", text:"Provide either 'impactManifestPath' or 'fromRef' to compute impacted tests." }], isError: true };
    }

    const resolvedRoots = searchRoots && searchRoots.length ? searchRoots : cfg.searchRoots;
    const { tests, details } = await computeImpactedApexTests({ repoDir, manifestPath: impactManifestPath, fromRef, toRef, searchRoots: resolvedRoots, maxFiles });

    let testLevel: "NoTestRun" | "RunSpecifiedTests" = "NoTestRun";
    let testList: string[] | undefined = undefined;
    if (tests.length > 0) {
      testLevel = "RunSpecifiedTests";
      testList = tests;
    } else if (!deployWhenNoTests) {
      return { content:[{ type:"text", text: JSON.stringify({ message: "No impacted tests found; deploy aborted as requested.", details }, null, 2) }], isError: false };
    }

    const res = await trySfDeploy(repoDir, {
      org: targetOrg,
      sourceDirs: deploySourceDirs,
      manifestPath: deployManifestPath,
      metadata: deployMetadata,
      testLevel,
      tests: testList,
      checkOnly,
      ignoreConflicts,
      waitSeconds,
      json
    });

    const payload = {
      impacted: { tests, details },
      deploy: { exitCode: res.code, attempts: res.attempts }
    };
    return { content:[{ type:"text", text: JSON.stringify(payload, null, 2) }], isError: res.code !== 0 };
  }
);

await server.connect(new StdioServerTransport());
