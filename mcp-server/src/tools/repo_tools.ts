/**
 * repo_tools.ts keeps documentation in sync: repoToolsCatalog shells to the local MCP CLI to list tools
 * and writes catalog JSON, while repoSyncToolDocs injects that catalog into README/AGENTS/.mcp.project.json
 * so humans and agents share a single source of truth.
 */import path from 'path';
import fs from 'fs-extra';
import { resolveProject } from '../lib/resolver.js';
import { ensureDir, writeJson, readJson, writeText, readText, exists } from '../lib/fsx.js';
import { sh } from '../lib/exec.js';

type ToolSummary = { name: string; title: string; description: string; inputs: string[] };

async function findProjectRoot(startDir: string): Promise<string> {
  let dir = path.resolve(startDir);
  // Walk up to locate package.json as an anchor for server root
  for (let i = 0; i < 6; i++) {
    const pkg = path.join(dir, 'package.json');
    if (await fs.pathExists(pkg)) return dir;
    const parent = path.dirname(dir);
    if (parent === dir) break;
    dir = parent;
  }
  return path.resolve(startDir);
}

async function listToolsViaCli(serverRoot: string): Promise<ToolSummary[]> {
  const distServer = path.join(serverRoot, 'dist', 'server.js');
  const existsDist = await fs.pathExists(distServer);
  if (!existsDist) {
    throw new Error(`dist/server.js not found at ${distServer}. Run \`npm run build\` first.`);
  }
  // The CLI parser expects an arg in the toolName position even for `list`,
  // so pass a harmless placeholder to enable --json output.
  const out = await sh('node', [distServer, 'list', 'noop', '--json'], serverRoot);
  const arr: ToolSummary[] = JSON.parse(out);
  return arr;
}

function renderToolBullets(tools: ToolSummary[]): string {
  const lines: string[] = [];
  for (const t of tools) {
    const inputs = t.inputs && t.inputs.length ? t.inputs.join(', ') : '(none)';
    lines.push(`- ${t.name} — ${t.title}`);
    lines.push(`  ${t.description}`);
    lines.push(`  inputs: ${inputs}`);
    lines.push('');
  }
  return lines.join('\n');
}

function injectSection(markId: string, title: string, body: string, existing?: string): { updated: string; changed: boolean } {
  const start = `<!-- ${markId}:start -->`;
  const end = `<!-- ${markId}:end -->`;
  const section = `\n## ${title}\n${start}\n${body}\n${end}\n`;
  if (!existing || !existing.trim()) {
    return { updated: section.trimStart() + '\n', changed: true };
  }
  const has = existing.includes(start) && existing.includes(end);
  if (!has) {
    // Append to end
    const updated = existing.endsWith('\n') ? existing + section : existing + '\n' + section;
    return { updated, changed: true };
  }
  const before = existing.split(start)[0];
  const after = existing.split(end)[1] || '';
  const updated = `${before}${start}\n${body}\n${end}${after}`;
  const changed = updated !== existing;
  return { updated, changed };
}

export async function repoToolsCatalog(repoDir: string, writeFile: boolean = true) {
  const serverRoot = await findProjectRoot(process.cwd());
  const tools = await listToolsViaCli(serverRoot);
  const cfg = await resolveProject(repoDir);
  const outDir = path.join(repoDir, cfg.artifactsDir || '.artifacts', 'catalog');
  const outPath = path.join(outDir, 'tools.json');
  if (writeFile) {
    await ensureDir(outDir);
    await writeJson(outPath, { generatedAt: new Date().toISOString(), count: tools.length, tools });
  }
  return { ok: true, count: tools.length, outPath, tools };
}

export async function repoSyncToolDocs(args: {
  repoDir: string;
  sectionTitle?: string;
  readmePath?: string;
  agentsPath?: string;
  mcpConfigPath?: string;
  dryRun?: boolean;
}) {
  const { repoDir, sectionTitle = 'MCP Tools', dryRun = false } = args;
  const serverRoot = await findProjectRoot(process.cwd());
  const { tools } = await repoToolsCatalog(repoDir, !dryRun);
  const bullets = renderToolBullets(tools);

  const readmePath = args.readmePath || path.join(repoDir, 'README.md');
  const agentsPath = args.agentsPath || path.join(repoDir, 'AGENTS.md');
  const mcpConfigPath = args.mcpConfigPath || path.join(repoDir, '.mcp.project.json');

  const markId = 'mcp-tools';
  const updates: { file: string; changed: boolean }[] = [];

  // README.md
  let readmeSrc = '';
  try { readmeSrc = await readText(readmePath); } catch {}
  const readmeUpdated = injectSection(markId, sectionTitle, bullets, readmeSrc);
  if (!dryRun && readmeUpdated.changed) await writeText(readmePath, readmeUpdated.updated);
  updates.push({ file: readmePath, changed: readmeUpdated.changed });

  // AGENTS.md
  let agentsSrc = '';
  try { agentsSrc = await readText(agentsPath); } catch {}
  const agentsUpdated = injectSection(markId, sectionTitle, bullets, agentsSrc);
  if (!dryRun && agentsUpdated.changed) await writeText(agentsPath, agentsUpdated.updated);
  updates.push({ file: agentsPath, changed: agentsUpdated.changed });

  // .mcp.project.json
  let cfg: any = {};
  try { cfg = await readJson(mcpConfigPath); } catch { cfg = {}; }
  const relCatalog = path.posix.join((await resolveProject(repoDir)).artifactsDir || '.artifacts', 'catalog', 'tools.json');
  const beforeCfg = JSON.stringify(cfg);
  if (!cfg.artifactsDir) cfg.artifactsDir = (await resolveProject(repoDir)).artifactsDir || '.artifacts';
  cfg.toolCatalog = {
    path: relCatalog,
    updatedAt: new Date().toISOString(),
    sourceServerRoot: serverRoot,
  };
  const afterCfg = JSON.stringify(cfg);
  const cfgChanged = beforeCfg !== afterCfg;
  if (!dryRun && cfgChanged) await writeJson(mcpConfigPath, cfg);
  updates.push({ file: mcpConfigPath, changed: cfgChanged });

  return {
    ok: true,
    updated: updates,
    count: tools.length,
    catalogPath: path.join(repoDir, relCatalog),
    dryRun,
  };
}

