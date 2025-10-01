import { execa } from 'execa';
export async function sh(cmd, args, cwd) {
    const { stdout } = await execa(cmd, args, { cwd });
    return stdout;
}
export async function trySh(cmd, args, cwd) {
    try {
        return await sh(cmd, args, cwd);
    }
    catch (e) {
        return e?.stdout || e?.shortMessage || String(e);
    }
}
