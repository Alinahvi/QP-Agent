import { existsSync } from "node:fs";
import { dirname, join } from "node:path";
export function resolveNpmCmd() {
    if (process.platform !== "win32")
        return "npm";
    const candidates = [
        join(dirname(process.execPath), "npm.cmd"),
        "C:/Program Files/nodejs/npm.cmd",
        "C:/Program Files (x86)/nodejs/npm.cmd",
        join(process.env.APPDATA || "", "npm", "npm.cmd"),
        "npm.cmd",
    ];
    for (const candidate of candidates) {
        try {
            if (candidate.endsWith(".cmd")) {
                if (existsSync(candidate))
                    return candidate;
            }
            else {
                if (existsSync(candidate))
                    return candidate;
            }
        }
        catch {
            // ignore
        }
    }
    return "npm.cmd";
}
export function codexAbs() {
    return join(process.env.APPDATA ?? "", "npm", "codex.cmd");
}
export function npxAbs() {
    return join(dirname(process.execPath), "npx.cmd");
}
export function resolveGeminiCmd() {
    if (process.platform !== "win32")
        return ["gemini"];
    const guesses = [
        join(process.env.APPDATA ?? "", "npm", "gai.cmd"),
        join(process.env.APPDATA ?? "", "npm", "gemini.cmd"),
        join(dirname(process.execPath), "gai.cmd"),
        join(dirname(process.execPath), "gemini.cmd"),
        "gai.cmd",
        "gemini.cmd",
    ];
    return guesses.filter((guess) => {
        if (!guess.endsWith(".cmd"))
            return true;
        try {
            return existsSync(guess);
        }
        catch {
            return false;
        }
    });
}
export function gitCandidates() {
    const list = [];
    if (process.platform === "win32") {
        list.push("git.exe");
        const pf = process.env["ProgramFiles"] || "C:/Program Files";
        const pf86 = process.env["ProgramFiles(x86)"] || "C:/Program Files (x86)";
        const guesses = [
            join(pf, "Git", "bin", "git.exe"),
            join(pf, "Git", "cmd", "git.exe"),
            join(pf86, "Git", "bin", "git.exe"),
            join(pf86, "Git", "cmd", "git.exe"),
        ];
        for (const guess of guesses) {
            try {
                if (existsSync(guess))
                    list.push(guess);
            }
            catch {
                // ignore
            }
        }
    }
    else {
        list.push("git");
    }
    return list;
}
export function sfCandidates() {
    const list = [];
    if (process.platform === "win32") {
        const pf = process.env["ProgramFiles"] || "C:/Program Files";
        const pf86 = process.env["ProgramFiles(x86)"] || "C:/Program Files (x86)";
        const localApp = process.env["LOCALAPPDATA"] || "C:/Users/Public/AppData/Local";
        const guesses = [
            join(dirname(process.execPath), "sf.cmd"),
            join(process.env.APPDATA || "", "npm", "sf.cmd"),
            join(pf, "Salesforce CLI", "bin", "sf.cmd"),
            join(pf86, "Salesforce CLI", "bin", "sf.cmd"),
            join(localApp, "sf", "bin", "sf.exe"),
        ];
        for (const guess of guesses) {
            try {
                if (existsSync(guess))
                    list.push(guess);
            }
            catch {
                // ignore
            }
        }
        list.push("sf.cmd");
        list.push("sf.exe");
    }
    else {
        list.push("sf");
    }
    return list;
}
