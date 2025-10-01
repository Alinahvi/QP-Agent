import { spawn } from "node:child_process";
function quoteArg(arg) {
    if (arg === "")
        return '""';
    if (/[^A-Za-z0-9@%_=+:,./-]/.test(arg)) {
        return '"' + arg.replace(/(["\\])/g, "\\$1") + '"';
    }
    return arg;
}
export function formatCommand(cmd, args) {
    return [cmd, ...args].map(quoteArg).join(" ");
}
export async function runCommand(cmd, args, options) {
    const { cwd, env, timeoutMs = 1_800_000, input } = options;
    return await new Promise((resolve) => {
        const child = spawn(cmd, args, { cwd, env, stdio: "pipe" });
        let stdout = "";
        let stderr = "";
        let finished = false;
        const start = Date.now();
        let timedOut = false;
        const complete = (code, error) => {
            if (finished)
                return;
            finished = true;
            clearTimeout(timeoutHandle);
            resolve({
                code,
                stdout,
                stderr,
                durationMs: Date.now() - start,
                timedOut,
                error,
            });
        };
        child.stdout?.on("data", (chunk) => {
            stdout += chunk.toString();
        });
        child.stderr?.on("data", (chunk) => {
            stderr += chunk.toString();
        });
        child.on("error", (err) => {
            complete(-1, err instanceof Error ? err.message : String(err));
        });
        child.on("close", (code) => {
            complete(code);
        });
        if (input !== undefined) {
            child.stdin?.write(input, (err) => {
                if (err) {
                    stderr += `\nstdin write error: ${err instanceof Error ? err.message : String(err)}`;
                }
                child.stdin?.end();
            });
        }
        else {
            child.stdin?.end();
        }
        const timeoutHandle = setTimeout(() => {
            timedOut = true;
            try {
                child.kill("SIGKILL");
            }
            catch (err) {
                stderr += `\nkill error: ${err instanceof Error ? err.message : String(err)}`;
            }
        }, timeoutMs);
    });
}
