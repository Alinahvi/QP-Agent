import { execa } from 'execa';

export async function sh(cmd: string, args: string[], cwd: string) {
  const { stdout } = await execa(cmd, args, { cwd });
  return stdout;
}

export async function trySh(cmd: string, args: string[], cwd: string) {
  try { return await sh(cmd, args, cwd); } catch (e:any) { return e?.stdout || e?.shortMessage || String(e); }
}
