import fs from "node:fs";
import path from "node:path";

const TOOL_VERSION = "0.1.0";

/**
 * Reads and parses JSON from a file path.
 *
 * Returns null when parsing fails so the caller can provide user-facing
 * guidance without crashing.
 *
 * @param {string} filePath Absolute path to a JSON file.
 * @returns {any|null} Parsed JSON object.
 */
function readJsonSafe(filePath) {
  try {
    return JSON.parse(fs.readFileSync(filePath, "utf8"));
  } catch {
    return null;
  }
}

/**
 * Reads a UTF-8 text file.
 *
 * Returns null when reading fails so callers can surface missing configs
 * without crashing.
 *
 * @param {string} filePath Absolute path to a text file.
 * @returns {string|null} File contents.
 */
function readTextSafe(filePath) {
  try {
    return fs.readFileSync(filePath, "utf8");
  } catch {
    return null;
  }
}

/**
 * Checks whether a path exists and is a regular file.
 *
 * @param {string} filePath Absolute or relative file path.
 * @returns {boolean} True when the path exists and is a file.
 */
function isFile(filePath) {
  try {
    return fs.statSync(filePath).isFile();
  } catch {
    return false;
  }
}

/**
 * Checks whether a Composer package name looks like a stub bundle.
 *
 * PHP projects use a variety of naming conventions for stub packages. This
 * helper keeps detection generic by treating any dependency containing "stubs"
 * as a candidate.
 *
 * @param {string} packageName Composer package name.
 * @returns {boolean} True when the package name includes "stubs".
 */
function isStubPackageName(packageName) {
  if (typeof packageName !== "string") return false;
  return packageName.toLowerCase().includes("stubs");
}

/**
 * Normalizes Composer script entries into a flat list of commands.
 *
 * Composer allows scripts to be strings or arrays. This helper provides a
 * consistent format for analysis.
 *
 * @param {unknown} value Composer script value.
 * @returns {string[]} Command list.
 */
function normalizeComposerScript(value) {
  if (typeof value === "string") return [value];
  if (Array.isArray(value)) return value.filter((x) => typeof x === "string");
  return [];
}

/**
 * Detects which Composer scripts invoke PHPStan.
 *
 * This helps the agent prefer the repo's own invocation (memory limits,
 * config, bootstrap files) instead of guessing.
 *
 * @param {Record<string, unknown>} scripts Composer scripts block.
 * @returns {Array<{name: string, commands: string[]}>} Matching script entries.
 */
function findPhpstanScripts(scripts) {
  if (!scripts || typeof scripts !== "object") return [];

  const matches = [];

  for (const [name, raw] of Object.entries(scripts)) {
    const commands = normalizeComposerScript(raw);

    const invokesPhpstan = commands.some((cmd) => {
      if (typeof cmd !== "string") return false;
      return cmd.includes("phpstan") || cmd.includes("vendor/bin/phpstan");
    });

    if (!invokesPhpstan) continue;

    matches.push({ name, commands });
  }

  return matches;
}

/**
 * Chooses a recommended command for running PHPStan in the current repo.
 *
 * The intent is to prefer an existing Composer script (often has correct
 * config, bootstrap, and memory limits), falling back to vendor binaries.
 *
 * @param {Array<{name: string, commands: string[]}>} phpstanScripts Matching Composer scripts.
 * @param {{binaryRelPath: string|null, configRelPath: string|null}} fallbackInfo Fallback discovery.
 * @returns {{command: string|null, rationale: string}} Suggested command and why.
 */
function suggestCommand(phpstanScripts, fallbackInfo) {
  const preferred = phpstanScripts.find((s) => s.name === "phpstan");
  if (preferred) {
    return {
      command: `composer run ${preferred.name}`,
      rationale: "Uses the repo's Composer script (preferred for consistent config).",
    };
  }

  if (phpstanScripts.length > 0) {
    return {
      command: `composer run ${phpstanScripts[0].name}`,
      rationale: "Uses the repo's Composer script that invokes PHPStan.",
    };
  }

  if (!fallbackInfo.binaryRelPath) {
    return {
      command: null,
      rationale: "No PHPStan binary detected under vendor/bin and no Composer script found.",
    };
  }

  const configArg = fallbackInfo.configRelPath ? ` -c ${fallbackInfo.configRelPath}` : "";

  return {
    command: `${fallbackInfo.binaryRelPath} analyse${configArg}`,
    rationale: "Falls back to vendor/bin/phpstan with an explicit config when needed.",
  };
}

/**
 * Extracts string-based hints from a phpstan.neon config.
 *
 * This does not parse NEON. It only checks for common tokens so the agent can
 * avoid guessing whether stub packages are referenced.
 *
 * @param {string} configText Raw phpstan config contents.
 * @param {string[]} stubPackageNames Stub packages declared in composer.json.
 * @returns {{mentionsScanDirectories: boolean, mentionsScanFiles: boolean, stubPackages: Array<{name: string, mentioned: boolean, matchedToken: string|null}>}} Hints.
 */
function buildConfigHints(configText, stubPackageNames) {
  const t = configText.toLowerCase();

  const stubPackages = Array.isArray(stubPackageNames)
    ? stubPackageNames
      .filter((name) => typeof name === "string" && name.length > 0)
      .map((name) => {
        const normalized = name.toLowerCase();
        const baseName = normalized.split("/").pop() ?? normalized;

        const tokens = [`vendor/${normalized}`, normalized];

        if (baseName && baseName !== "stubs") tokens.push(baseName);

        const matchedToken = tokens.find((token) => t.includes(token)) ?? null;

        return {
          name,
          mentioned: Boolean(matchedToken),
          matchedToken,
        };
      })
      .sort((a, b) => a.name.localeCompare(b.name))
    : [];

  return {
    mentionsScanDirectories: t.includes("scandirectories"),
    mentionsScanFiles: t.includes("scanfiles"),
    stubPackages,
  };
}

/**
 * Extracts stub-like package references from a PHPStan config.
 *
 * The PHPStan config usually references stubs via vendor paths (for example,
 * "vendor/php-stubs/wordpress-stubs"), so this helper focuses on composer-style
 * "vendor/package" tokens containing "stubs".
 *
 * @param {string} configText Raw phpstan config contents.
 * @returns {string[]} Unique, lowercased composer-style package references.
 */
function extractStubPackageReferences(configText) {
  const matches = configText
    .toLowerCase()
    .match(/\b[a-z0-9_.-]+\/[a-z0-9_.-]*stubs[a-z0-9_.-]*\b/g);

  if (!matches) return [];

  return [...new Set(matches)].sort();
}

/**
 * Builds a JSON report describing the current repository's PHPStan setup.
 *
 * @returns {object} A stable, machine-readable inspection report.
 */
function buildReport() {
  const repoRoot = process.cwd();

  const composerPath = path.join(repoRoot, "composer.json");
  const composer = isFile(composerPath) ? readJsonSafe(composerPath) : null;

  const phpstanConfigFiles = ["phpstan.neon", "phpstan.neon.dist"].filter((f) =>
    isFile(path.join(repoRoot, f))
  );
  const phpstanBaselineFiles = ["phpstan-baseline.neon", "phpstan-baseline.neon.dist"].filter((f) =>
    isFile(path.join(repoRoot, f))
  );

  let configRelPath = null;
  if (phpstanConfigFiles.includes("phpstan.neon")) configRelPath = "phpstan.neon";
  else if (phpstanConfigFiles.includes("phpstan.neon.dist")) configRelPath = "phpstan.neon.dist";

  const configAbsPath = configRelPath ? path.join(repoRoot, configRelPath) : null;
  const configText = configAbsPath ? readTextSafe(configAbsPath) : null;

  const binaryRelPath = isFile(path.join(repoRoot, "vendor", "bin", "phpstan")) ? "vendor/bin/phpstan" : null;

  const composerScripts = composer?.scripts && typeof composer.scripts === "object" ? composer.scripts : null;
  const phpstanScripts = composerScripts ? findPhpstanScripts(composerScripts) : [];

  const deps = {
    phpstan: [],
    wordpress: [],
    stubs: [],
  };

  const stubPackageMeta = new Map();

  /**
   * Collects dependency names that match certain heuristics.
   *
   * This keeps inspection deterministic while still surfacing common
   * WordPress/PHPStan packages used for typing support.
   *
   * @param {Record<string, unknown>} depsBlock Composer require/require-dev block.
   * @param {"require"|"require-dev"} scope Dependency block the packages came from.
   */
  function collectDeps(depsBlock, scope) {
    if (!depsBlock || typeof depsBlock !== "object") return;

    for (const [name, constraint] of Object.entries(depsBlock)) {
      if (name.includes("phpstan")) deps.phpstan.push(name);
      if (name.includes("wordpress")) deps.wordpress.push(name);

      if (!isStubPackageName(name)) continue;

      deps.stubs.push(name);

      const versionConstraint = typeof constraint === "string" ? constraint : null;
      const existing = stubPackageMeta.get(name);

      if (!existing) {
        stubPackageMeta.set(name, {
          name,
          versionConstraint,
          scopes: new Set([scope]),
        });
        continue;
      }

      existing.scopes.add(scope);
      if (!existing.versionConstraint && versionConstraint) existing.versionConstraint = versionConstraint;
    }
  }

  if (composer?.require && typeof composer.require === "object") {
    collectDeps(composer.require, "require");
  }

  if (composer?.["require-dev"] && typeof composer["require-dev"] === "object") {
    collectDeps(composer["require-dev"], "require-dev");
  }

  const stubPackageNames = [...new Set(deps.stubs)].sort();
  const stubPackages = Array.from(stubPackageMeta.values())
    .map((pkg) => ({
      name: pkg.name,
      versionConstraint: pkg.versionConstraint,
      scopes: [...pkg.scopes].sort(),
    }))
    .sort((a, b) => a.name.localeCompare(b.name));

  const configHints = configText ? buildConfigHints(configText, stubPackageNames) : null;

  const suggested = suggestCommand(phpstanScripts, {
    binaryRelPath,
    configRelPath: configRelPath === "phpstan.neon" ? null : configRelPath,
  });

  const notes = [];

  if (!composer) notes.push("No composer.json found; PHPStan is usually installed via Composer.");
  if (phpstanConfigFiles.length === 0) notes.push("No phpstan.neon or phpstan.neon.dist found at repo root.");
  if (!binaryRelPath && phpstanScripts.length === 0) notes.push("No PHPStan entrypoint detected (Composer script or vendor/bin/phpstan).");

  if (configText) {
    const referencedStubPackages = extractStubPackageReferences(configText);
    const installedStubPackages = new Set(stubPackageNames.map((name) => name.toLowerCase()));
    const missingStubPackages = referencedStubPackages.filter((name) => !installedStubPackages.has(name));

    if (missingStubPackages.length > 0) {
      notes.push(
        `PHPStan config references stub package(s) not declared in composer.json: ${missingStubPackages.join(
          ", "
        )}. Ensure they are installed or update the config paths.`
      );
    }
  }

  if (configHints) {
    const unmentionedStubPackages = configHints.stubPackages
      .filter((pkg) => !pkg.mentioned)
      .map((pkg) => pkg.name);

    if (unmentionedStubPackages.length > 0) {
      notes.push(
        `Stub package(s) are installed but not obviously referenced in the PHPStan config: ${unmentionedStubPackages.join(
          ", "
        )}. Ensure stubs are loaded.`
      );
    }
  }

  return {
    tool: { name: "phpstan_inspect", version: TOOL_VERSION },
    repoRoot,
    composer: {
      exists: Boolean(composer),
      path: isFile(composerPath) ? "composer.json" : null,
      phpstanScripts,
      dependencies: {
        phpstan: [...new Set(deps.phpstan)].sort(),
        wordpress: [...new Set(deps.wordpress)].sort(),
        stubs: stubPackageNames,
        stubPackages,
      },
    },
    phpstan: {
      configFiles: phpstanConfigFiles,
      baselineFiles: phpstanBaselineFiles,
      config: {
        primary: configRelPath,
        hints: configHints,
      },
      binary: {
        vendorBin: binaryRelPath,
      },
    },
    suggested,
    notes,
  };
}

/**
 * CLI entrypoint for printing the inspection report.
 */
function main() {
  const report = buildReport();
  process.stdout.write(`${JSON.stringify(report, null, 2)}\n`);
}

main();
