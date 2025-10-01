import fs from 'fs-extra';
import * as path from 'path';

export async function ensureDir(p: string) { await fs.ensureDir(p); }
export async function writeText(p: string, s: string) {
  await ensureDir(path.dirname(p)); await fs.writeFile(p, s, 'utf8');
}
export async function readText(p: string) { return await fs.readFile(p,'utf8'); }
export async function exists(p: string) { return await fs.pathExists(p); }
export async function readJson<T=any>(p: string): Promise<T> { return JSON.parse(await readText(p)); }
export async function writeJson(p: string, obj: any) { await writeText(p, JSON.stringify(obj, null, 2)); }
