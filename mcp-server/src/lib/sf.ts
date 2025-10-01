import * as path from 'path';
import fs from 'fs-extra';
import { randomUUID } from 'crypto';
import { sh, trySh } from './exec.js';

function sanitizeJsonOutput(raw: string): string {
  const trimmed = raw.trim();
  if (!trimmed) return trimmed;
  const braceIndex = trimmed.indexOf('{');
  const bracketIndex = trimmed.indexOf('[');
  let start = -1;
  if (braceIndex >= 0 && bracketIndex >= 0) {
    start = Math.min(braceIndex, bracketIndex);
  } else if (braceIndex >= 0) {
    start = braceIndex;
  } else if (bracketIndex >= 0) {
    start = bracketIndex;
  }
  if (start >= 0) {
    return trimmed.slice(start);
  }
  return trimmed;
}

async function sleep(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

type AgentTestOptions = {
  packPath?: string;
  agentApiName?: string;
  definitionName?: string;
  utterances?: string[];
  context?: Record<string, any>;
  capture?: string[];
  mode?: string;
  scope?: string;
  maxTurns?: number;
  waitMinutes?: number;
  ticketId?: string;
};

export async function sfAvailable(repoDir: string): Promise<boolean> {
  const out = await trySh('sf', ['--version'], repoDir);
  return /sf cli/i.test(out) || /salesforce cli/i.test(out) || /@salesforce\//i.test(out);
}

export async function deployManifest(repoDir: string, org: string, manifestPath: string) {
  return trySh('sf', [
    'project',
    'deploy',
    'start',
    '-x',
    manifestPath,
    '-u',
    org,
    '-l',
    'NoTestRun',
    '--ignore-conflicts',
    '--json',
  ], repoDir);
}

export async function apexRunSpecified(
  repoDir: string,
  org: string,
  tests: string[],
  waitSeconds = 2400,
) {
  const list = tests.join(',');
  return trySh('sf', [
    'apex',
    'run',
    'test',
    '--tests',
    list,
    '-u',
    org,
    '--wait',
    String(waitSeconds),
    '--result-format',
    'junit',
    '--json',
  ], repoDir);
}

export async function apexRunSuites(
  repoDir: string,
  org: string,
  suites: string[],
  waitSeconds = 2400,
) {
  const list = suites.join(',');
  return trySh('sf', [
    'apex',
    'run',
    'test',
    '--suite-names',
    list,
    '-u',
    org,
    '--wait',
    String(waitSeconds),
    '--result-format',
    'junit',
    '--json',
  ], repoDir);
}

export async function assignPermissionSet(repoDir: string, org: string, permissionSetName: string) {
  return trySh('sf', [
    'org',
    'permset',
    'assign',
    '--name',
    permissionSetName,
    '--target-org',
    org,
    '--json',
  ], repoDir);
}

export async function runAgentTest(repoDir: string, org: string, opts: AgentTestOptions) {
  const waitMinutes = opts.waitMinutes ?? 5;

  // Determine CLI capabilities
  const einsteinHelp = await trySh('sf', ['help', 'einstein'], repoDir);
  const hasEinstein = !/Command einstein not found/i.test(einsteinHelp);

  // If utterances are provided and Einstein plugin is available, use the pack-based runner
  if (hasEinstein && opts.utterances && opts.utterances.length) {
    const args = [
      'einstein',
      'agents',
      'testing',
      'run',
      '--target-org',
      org,
      '--wait',
      String(waitMinutes),
      '--json',
    ];
    if (opts.definitionName) args.push('--definition-name', opts.definitionName);
    if (opts.agentApiName) args.push('--agent-api-name', opts.agentApiName);
    if (opts.scope) args.push('--scope', opts.scope);
    if (opts.mode) args.push('--mode', opts.mode);
    if (opts.capture && opts.capture.length) args.push('--capture', opts.capture.join(','));
    if (typeof opts.maxTurns === 'number') args.push('--max-turns', String(opts.maxTurns));

    let packPath = opts.packPath;
    if (!packPath) {
      const tmpDir = path.join(repoDir, '.artifacts', 'tmp', 'agent');
      await fs.ensureDir(tmpDir);
      packPath = path.join(tmpDir, `${opts.ticketId || 'pack'}-${randomUUID()}.json`);
      const packPayload = {
        agentApiName: opts.agentApiName,
        utterances: opts.utterances,
        context: opts.context || {},
        mode: opts.mode ?? 'non_destructive',
        capture: opts.capture && opts.capture.length ? opts.capture : ['transcript', 'actions', 'metrics'],
        maxTurns: opts.maxTurns ?? 1,
      };
      await fs.writeJson(packPath, packPayload, { spaces: 2 });
    }
    args.push('--pack', packPath);
    return { raw: await trySh('sf', args, repoDir), packPath };
  }

  // Fallback: use built-in Agent Test runner by API name (AiEvaluationDefinition)
  // Note: This path does not accept custom utterances. It executes an existing Agent Test in the org.
  const args = [
    'agent',
    'test',
    'run',
    '--target-org',
    org,
    '--wait',
    String(waitMinutes),
    '--result-format',
    'json',
  ];
  // Prefer definitionName when provided; otherwise assume agentApiName refers to the test API name
  const testApiName = opts.definitionName || opts.agentApiName;
  if (testApiName) args.push('--api-name', testApiName);
  return { raw: await trySh('sf', args, repoDir), packPath: undefined };
}

// Back-compat helper for legacy callers
export async function agentRun(repoDir: string, org: string, defName?: string, waitMins = 15) {
  const result = await runAgentTest(repoDir, org, { definitionName: defName, waitMinutes: waitMins });
  return result.raw;
}

export async function dataQuery(
  repoDir: string,
  org: string,
  soql: string,
): Promise<{ records: any[]; raw: string }> {
  let last = '';
  for (let i = 0; i < 3; i++) {
    const out = await trySh('sf', ['data', 'query', '-q', soql, '-u', org, '--json'], repoDir);
    last = out;
    try {
      const sanitized = sanitizeJsonOutput(out);
      const j = JSON.parse(sanitized);
      const records = j?.result?.records || [];
      return { records, raw: out };
    } catch (err) {
      await sleep(300 * (i + 1));
    }
  }
  return { records: [], raw: last };
}

export async function toolingQuery(
  repoDir: string,
  org: string,
  soql: string,
): Promise<{ records: any[]; raw: string }> {
  let last = '';
  for (let i = 0; i < 3; i++) {
    const out = await trySh('sf', ['data', 'query', '-q', soql, '-u', org, '--use-tooling-api', '--json'], repoDir);
    last = out;
    try {
      const sanitized = sanitizeJsonOutput(out);
      const j = JSON.parse(sanitized);
      const records = j?.result?.records || [];
      return { records, raw: out };
    } catch (err) {
      await sleep(300 * (i + 1));
    }
  }
  return { records: [], raw: last };
}

