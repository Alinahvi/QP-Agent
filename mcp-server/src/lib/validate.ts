import fs from 'fs-extra';
import path from 'path';
import Ajv from 'ajv';

export type ValidationResult = { ok: boolean; errors?: any[] };

export async function validateJsonAgainstSchema(jsonPath: string, schemaPath: string): Promise<ValidationResult> {
  const ajv = new Ajv({ allErrors: true, strict: false });
  const [dataText, schemaText] = await Promise.all([
    fs.readFile(jsonPath, 'utf8').catch(() => ''),
    fs.readFile(schemaPath, 'utf8').catch(() => ''),
  ]);
  if (!dataText || !schemaText) return { ok: false, errors: [{ message: 'Missing data or schema' }] };
  const data = JSON.parse(dataText);
  const schema = JSON.parse(schemaText);
  const validate = ajv.compile(schema);
  const ok = validate(data) as boolean;
  return ok ? { ok } : { ok: false, errors: validate.errors || [] };
}

export async function writeValidationReport(outDir: string, name: string, result: ValidationResult) {
  await fs.ensureDir(outDir);
  const outPath = path.join(outDir, `validation-${name}.json`);
  await fs.writeJson(outPath, result, { spaces: 2 });
  return outPath;
}

