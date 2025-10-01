import * as path from 'path';
import fs from 'fs-extra';
import Mustache from 'mustache';

export async function renderToFile(tplPath: string, view: any, outPath: string) {
  const tpl = await fs.readFile(tplPath, 'utf8');
  const txt = Mustache.render(tpl, view);
  await fs.ensureDir(path.dirname(outPath));
  await fs.writeFile(outPath, txt, 'utf8');
  return outPath;
}

export async function renderToFileWithFallback(
  tplPath: string,
  fallbackTemplate: string,
  view: any,
  outPath: string
) {
  let tpl: string;
  try {
    tpl = await fs.readFile(tplPath, 'utf8');
  } catch {
    tpl = fallbackTemplate;
  }
  const txt = Mustache.render(tpl, view);
  await fs.ensureDir(path.dirname(outPath));
  await fs.writeFile(outPath, txt, 'utf8');
  return outPath;
}
