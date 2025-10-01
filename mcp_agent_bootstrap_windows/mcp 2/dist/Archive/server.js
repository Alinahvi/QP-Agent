// C:\Users\gardi\MCP\src\server.ts
// -----------------------------------------------------------------------------
// MCP server (Windows-hardened) WITHOUT injecting any Codex CLI flags.
// Codex policies (approvals/sandbox) must be set via ~/.codex/config.toml
// or in the interactive REPL (/approvals, /status).
// -----------------------------------------------------------------------------
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
import { spawn, exec as execCb } from "node:child_process";
import { promisify } from "node:util";
import { existsSync, statSync } from "node:fs";
import { join, dirname } from "node:path";
const exec = promisify(execCb);
const VERSION = "0.3.3-no-flags";
const server = new McpServer({ name: "sf-codex", version: VERSION });
// ---- helpers ----------------------------------------------------------------
function bin(name) {
    return process.platform === "win32" ? `${name}.cmd` : name;
}
function runSpawn(cmd, args, cwd, timeoutSec = 1800, env) {
    return new Promise((resolve) => {
        const p = spawn(cmd, args, { cwd, shell: false, windowsVerbatimArguments: false, env: { ...process.env, ...(env ?? {}) } });
        let out = "", err = "";
        const t = setTimeout(() => {
            try {
                p.kill("SIGKILL");
            }
            catch { }
            if (process.platform === "win32" && typeof p.pid === "number") {
                try {
                    spawn("taskkill", ["/PID", String(p.pid), "/T", "/F"], { stdio: "ignore" });
                }
                catch { }
            }
        }, timeoutSec * 1000);
        p.on("error", e => { clearTimeout(t); resolve({ code: -1, out, err: `spawn error: ${String(e)}` }); });
        p.stdout.on("data", d => out += d.toString());
        p.stderr.on("data", d => err += d.toString());
        p.on("close", c => { clearTimeout(t); resolve({ code: c, out, err }); });
    });
}
// --- Windows-safe exec helpers ----------------------------------------------
function resolveNpmCmd() {
    if (process.platform !== "win32")
        return "npm";
    const candidates = [
        join(dirname(process.execPath), "npm.cmd"),
        "C:\\Program Files\\nodejs\\npm.cmd",
        "C:\\Program Files (x86)\\nodejs\\npm.cmd",
        join(process.env.APPDATA || "", "npm", "npm.cmd"),
        "npm.cmd"
    ];
    for (const p of candidates) {
        try {
            if (existsSync(p))
                return p;
        }
        catch { }
    }
    return "npm.cmd";
}
async function execCmdLine(line, cwd, timeoutSec = 1800) {
    try {
        const { stdout, stderr } = await exec(line, {
            cwd,
            windowsHide: true,
            timeout: timeoutSec * 1000,
            maxBuffer: 64 * 1024 * 1024
        });
        return { code: 0, out: String(stdout ?? ""), err: String(stderr ?? "") };
    }
    catch (e) {
        return { code: e?.code ?? 1, out: String(e?.stdout ?? ""), err: String(e?.stderr ?? e) };
    }
}
async function runCmdLine(cmdline, cwd, timeoutSec = 1800) {
    try {
        const { stdout, stderr } = await exec(cmdline, {
            cwd,
            windowsHide: true,
            timeout: timeoutSec * 1000,
            maxBuffer: 64 * 1024 * 1024
        });
        return { code: 0, out: String(stdout ?? ""), err: String(stderr ?? "") };
    }
    catch (e) {
        return { code: e?.code ?? 1, out: String(e?.stdout ?? ""), err: String(e?.stderr ?? e) };
    }
}
function quoteForCmd(s) { return s.replace(/"/g, '""'); }
function codexAbs() { return join(process.env.APPDATA ?? "", "npm", "codex.cmd"); }
function npxAbs() { return join(dirname(process.execPath), "npx.cmd"); }
function npmAbs() { return join(dirname(process.execPath), "npm.cmd"); }
function ensureDir(path) {
    try {
        const st = statSync(path);
        if (!st.isDirectory())
            return `Not a directory: ${path}`;
        return null;
    }
    catch {
        return `Directory not found: ${path}`;
    }
}
// ---- tools ------------------------------------------------------------------
server.tool("ping", "Health check", async () => ({ content: [{ type: "text", text: `pong ${VERSION}` }] }));
// Run `codex exec "<task>"` in repoDir (no flags injected)
server.tool("codex_exec", "Run `codex exec <PROMPT>` inside repoDir (no flags injected; use ~/.codex/config.toml)", { repoDir: z.string(), task: z.string(), maxSeconds: z.number().int().positive().max(7200).default(1800) }, async ({ repoDir, task, maxSeconds }) => {
    const invalid = ensureDir(repoDir);
    if (invalid)
        return { content: [{ type: "text", text: invalid }], isError: true };
    const tried = [];
    const abs = codexAbs();
    if (process.platform === "win32" && existsSync(abs)) {
        const line = `"${abs}" exec "${quoteForCmd(task)}"`;
        tried.push(`cmd:${abs}`);
        const r1 = await runCmdLine(line, repoDir, maxSeconds);
        return { content: [{ type: "text", text: `tried: ${tried.join(" | ")}\nexit ${r1.code}\n--- stdout (last) ---\n${r1.out}\n--- stderr (last) ---\n${r1.err}` }], isError: r1.code !== 0 };
    }
    if (process.platform === "win32" && existsSync(npxAbs())) {
        const nx = npxAbs();
        tried.push(`cmd:${nx}`);
        const r2 = await runCmdLine(`"${nx}" -y codex exec "${quoteForCmd(task)}"`, repoDir, maxSeconds);
        return { content: [{ type: "text", text: `tried: ${tried.join(" | ")}\nexit ${r2.code}\n--- stdout (last) ---\n${r2.out}\n--- stderr (last) ---\n${r2.err}` }], isError: r2.code !== 0 };
    }
    tried.push("spawn:codex");
    const r3 = await runSpawn(bin("codex"), ["exec", task], repoDir, maxSeconds, { FORCE_COLOR: "0", CI: "1" });
    return { content: [{ type: "text", text: `tried: ${tried.join(" | ")}\nexit ${r3.code}\n--- stdout (last) ---\n${r3.out}\n--- stderr (last) ---\n${r3.err}` }], isError: r3.code !== 0 };
});
server.tool("jest_mcp", "npm run test:unit:mcp", { repoDir: z.string(), maxSeconds: z.number().int().default(1800) }, async ({ repoDir, maxSeconds }) => {
    const invalid = ensureDir(repoDir);
    if (invalid)
        return { content: [{ type: "text", text: invalid }], isError: true };
    const npm = resolveNpmCmd();
    const line = `"${npm}" run test:unit:mcp`;
    const r = await execCmdLine(line, repoDir, maxSeconds);
    return { content: [{ type: "text", text: `cmdline: ${line}\nexit ${r.code}\n${r.out}\n${r.err}` }], isError: r.code !== 0 };
});
server.tool("apex_mcp", "npm run test:apex:mcp", { repoDir: z.string(), maxSeconds: z.number().int().default(3600) }, async ({ repoDir, maxSeconds }) => {
    const invalid = ensureDir(repoDir);
    if (invalid)
        return { content: [{ type: "text", text: invalid }], isError: true };
    const npm = resolveNpmCmd();
    const line = `"${npm}" run test:apex:mcp`;
    const r = await execCmdLine(line, repoDir, maxSeconds);
    return { content: [{ type: "text", text: `cmdline: ${line}\nexit ${r.code}\n${r.out}\n${r.err}` }], isError: r.code !== 0 };
});
server.tool("analyze_mcp", "npm run analyze:mcp", { repoDir: z.string(), maxSeconds: z.number().int().default(1800) }, async ({ repoDir, maxSeconds }) => {
    const invalid = ensureDir(repoDir);
    if (invalid)
        return { content: [{ type: "text", text: invalid }], isError: true };
    const npm = resolveNpmCmd();
    const line = `"${npm}" run analyze:mcp`;
    const r = await execCmdLine(line, repoDir, maxSeconds);
    return { content: [{ type: "text", text: `cmdline: ${line}\nexit ${r.code}\n${r.out}\n${r.err}` }], isError: r.code !== 0 };
});
const qualityGateOutputShape = {
    pass: z.boolean(),
    results: z.array(z.object({
        step: z.string(),
        exitCode: z.number().nullable(),
        outTail: z.string(),
        errTail: z.string(),
        artifacts: z.array(z.object({ path: z.string(), exists: z.boolean() }))
    }))
};
const qualityGateTool = server.tool("quality_gate", "Runs Jest | Apex | Analyzer and summarizes artifacts", { repoDir: z.string(), stopOnFail: z.boolean().default(true) }, async ({ repoDir, stopOnFail }) => {
    const invalid = ensureDir(repoDir);
    if (invalid)
        return { content: [{ type: "text", text: invalid }], isError: true };
    const npm = resolveNpmCmd();
    const steps = [
        { name: "jest", line: `"${npm}" run test:unit:mcp`, arts: [join(repoDir, ".artifacts", "jest-junit.xml")] },
        { name: "apex", line: `"${npm}" run test:apex:mcp`, arts: [join(repoDir, ".artifacts", "tests")] },
        { name: "anlz", line: `"${npm}" run analyze:mcp`, arts: [join(repoDir, ".artifacts", "code-analysis.json")] }
    ];
    const results = [];
    let pass = true;
    for (const s of steps) {
        const r = await execCmdLine(s.line, repoDir, 2400);
        const ok = r.code === 0;
        pass = pass && ok;
        results.push({
            step: s.name,
            exitCode: r.code,
            outTail: r.out.slice(-1500),
            errTail: r.err.slice(-1500),
            artifacts: s.arts.map(p => ({ path: p, exists: existsSync(p) }))
        });
        if (!ok && stopOnFail)
            break;
    }
    const payload = { pass, results };
    return {
        content: [{ type: "text", text: JSON.stringify(payload, null, 2) }],
        isError: pass === false
    };
});
qualityGateTool.update({ outputSchema: qualityGateOutputShape });
// Graceful shutdown
for (const sig of ["SIGINT", "SIGTERM"]) {
    try {
        process.on(sig, async () => { try {
            await server.close();
        }
        catch { } process.exit(0); });
    }
    catch { }
}
await server.connect(new StdioServerTransport());
