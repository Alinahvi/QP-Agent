import fs from 'fs-extra';
import * as path from 'path';
export async function ensureDir(p) { await fs.ensureDir(p); }
export async function writeText(p, s) {
    await ensureDir(path.dirname(p));
    await fs.writeFile(p, s, 'utf8');
}
export async function readText(p) { return await fs.readFile(p, 'utf8'); }
export async function exists(p) { return await fs.pathExists(p); }
export async function readJson(p) { return JSON.parse(await readText(p)); }
export async function writeJson(p, obj) { await writeText(p, JSON.stringify(obj, null, 2)); }
