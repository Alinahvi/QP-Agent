import fs from "node:fs";
import path from "node:path";

export type ProjectConfig = {
  projectId?: string;
  defaultOrgAlias?: string;
  searchRoots?: string[];
  deploy?: { manifest?: string; sourceDirs?: string[] };
  apex?: {
    strategy?: "git-diff" | "suite" | "allowlist";
    fromRef?: string;
    suiteNames?: string[];
    allowlist?: string[];
  };
  agent?: {
    enabled?: boolean;
    definitionApiName?: string;
    specPath?: string;
    resultFormat?: "json" | "tap" | "junit";
    artifactDir?: string;
  };
  artifactsDir?: string;
};

type SfdxConfig = {
  defaultusername?: string;
  [key: string]: unknown;
};

type SfConfig = {
  "target-org"?: string;
  [key: string]: unknown;
};

export type ResolvedProjectConfig = {
  projectId: string;
  defaultOrgAlias: string;
  searchRoots: string[];
  deploy: { manifest?: string; sourceDirs: string[] };
  apex: {
    strategy: "git-diff" | "suite" | "allowlist";
    fromRef: string;
    suiteNames: string[];
    allowlist: string[];
  };
  agent: {
    enabled: boolean;
    definitionApiName: string;
    specPath: string;
    resultFormat: "json" | "tap" | "junit";
    artifactDir: string;
  };
  artifactsDir: string;
};

function readJsonIfExists<T = any>(filePath: string | undefined): T | undefined {
  if (!filePath) return undefined;
  try {
    if (!fs.existsSync(filePath)) return undefined;
    const raw = fs.readFileSync(filePath, "utf8");
    return JSON.parse(raw) as T;
  } catch {
    return undefined;
  }
}

function uniqueStrings(values: (string | undefined)[]): string[] {
  const seen = new Set<string>();
  const result: string[] = [];
  for (const value of values) {
    if (!value) continue;
    const normalized = value.replace(/\\+/g, "/");
    if (normalized.length === 0) continue;
    const normalizedLower = normalized.replace(/\/$/, "");
    if (seen.has(normalizedLower)) continue;
    seen.add(normalizedLower);
    result.push(normalizedLower);
  }
  return result;
}

function findDefaultAlias(cfg: ProjectConfig, repoRoot: string): string | undefined {
  if (cfg.defaultOrgAlias) return cfg.defaultOrgAlias;

  const envAlias = process.env.SF_TARGET_ORG || process.env.SFDX_DEFAULTUSERNAME;
  if (envAlias) return envAlias;

  const repoConfig = readJsonIfExists<SfdxConfig>(path.join(repoRoot, "sfdx-config.json"));
  if (repoConfig?.defaultusername) return repoConfig.defaultusername;

  const repoDotConfig = readJsonIfExists<SfdxConfig>(path.join(repoRoot, ".sfdx", "sfdx-config.json"));
  if (repoDotConfig?.defaultusername) return repoDotConfig.defaultusername;

  const home = process.env.HOME || process.env.USERPROFILE;
  if (home) {
    const globalSf = readJsonIfExists<SfConfig>(path.join(home, ".sf", "config.json"));
    if (globalSf?.["target-org"]) return globalSf["target-org"];

    const globalSfdx = readJsonIfExists<SfdxConfig>(path.join(home, ".sfdx", "sfdx-config.json"));
    if (globalSfdx?.defaultusername) return globalSfdx.defaultusername;
  }

  return undefined;
}

export function resolveProject(repoDir: string): ResolvedProjectConfig {
  const repoRoot = repoDir ? path.resolve(repoDir) : process.cwd();
  const cfgPath = path.join(repoRoot, ".mcp.project.json");
  const cfg = readJsonIfExists<ProjectConfig>(cfgPath) ?? {};

  const sfdxProject = readJsonIfExists<any>(path.join(repoRoot, "sfdx-project.json"));
  const derivedRoots: string[] = [];
  if (!cfg.searchRoots?.length && Array.isArray(sfdxProject?.packageDirectories)) {
    for (const entry of sfdxProject.packageDirectories) {
      if (!entry?.path || typeof entry.path !== "string") continue;
      const base = path.join(repoRoot, entry.path);
      derivedRoots.push(
        path.relative(repoRoot, path.join(base, "main", "default", "classes")),
        path.relative(repoRoot, path.join(base, "main", "default", "triggers"))
      );
    }
  }

  const alias = findDefaultAlias(cfg, repoRoot);
  if (!alias) {
    throw new Error(
      "No target org alias found. Configure one via .mcp.project.json, SF_TARGET_ORG, " +
        "SFDX_DEFAULTUSERNAME, or sf config set target-org=innovation --global."
    );
  }

  const searchRoots = cfg.searchRoots?.length ? cfg.searchRoots : derivedRoots;

  return {
    projectId: cfg.projectId ?? path.basename(repoRoot),
    defaultOrgAlias: alias,
    searchRoots: uniqueStrings(searchRoots ?? []),
    deploy: {
      manifest: cfg.deploy?.manifest,
      sourceDirs: cfg.deploy?.sourceDirs ?? []
    },
    apex: {
      strategy: cfg.apex?.strategy ?? "git-diff",
      fromRef: cfg.apex?.fromRef ?? "origin/main",
      suiteNames: cfg.apex?.suiteNames ?? [],
      allowlist: cfg.apex?.allowlist ?? []
    },
    agent: {
      enabled: cfg.agent?.enabled ?? false,
      definitionApiName: cfg.agent?.definitionApiName ?? "",
      specPath: cfg.agent?.specPath ?? "",
      resultFormat: cfg.agent?.resultFormat ?? "junit",
      artifactDir: cfg.agent?.artifactDir ?? ".artifacts/agent"
    },
    artifactsDir: cfg.artifactsDir ?? ".artifacts"
  };
}
