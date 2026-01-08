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
 * avoid guessing whether stub paths are referenced.
 *
 * @param {string} configText Raw phpstan config contents.
 * @returns {{mentionsScanDirectories: boolean, mentionsScanFiles: boolean, mentionsWordpressStubs: boolean, mentionsWoocommerceStubs: boolean, mentionsAcfProStubs: boolean}} Hints.
 */
function buildConfigHints(configText) {
  const t = configText.toLowerCase();

  return {
    mentionsScanDirectories: t.includes("scandirectories"),
    mentionsScanFiles: t.includes("scanfiles"),
    mentionsWordpressStubs: t.includes("wordpress-stubs"),
    mentionsWoocommerceStubs: t.includes("woocommerce-stubs"),
    mentionsAcfProStubs: t.includes("acf-pro-stubs"),
  };
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
  const configHints = configText ? buildConfigHints(configText) : null;

  const binaryRelPath = isFile(path.join(repoRoot, "vendor", "bin", "phpstan")) ? "vendor/bin/phpstan" : null;

  const composerScripts = composer?.scripts && typeof composer.scripts === "object" ? composer.scripts : null;
  const phpstanScripts = composerScripts ? findPhpstanScripts(composerScripts) : [];

  const deps = {
    phpstan: [],
    wordpress: [],
    stubs: [],
  };

  /**
   * Collects dependency names that match certain heuristics.
   *
   * This keeps inspection deterministic while still surfacing common
   * WordPress/PHPStan packages used for typing support.
   *
   * @param {Record<string, unknown>} depsBlock Composer require/require-dev block.
   */
  function collectDeps(depsBlock) {
    if (!depsBlock || typeof depsBlock !== "object") return;

    const names = Object.keys(depsBlock);

    deps.phpstan.push(...names.filter((k) => k.includes("phpstan")));
    deps.wordpress.push(...names.filter((k) => k.includes("wordpress")));

    deps.stubs.push(
      ...names.filter((k) => {
        if (k.startsWith("php-stubs/")) return true;
        return k.endsWith("-stubs");
      })
    );
  }

  if (composer?.require && typeof composer.require === "object") {
    collectDeps(composer.require);
  }

  if (composer?.["require-dev"] && typeof composer["require-dev"] === "object") {
    collectDeps(composer["require-dev"]);
  }

  const suggested = suggestCommand(phpstanScripts, {
    binaryRelPath,
    configRelPath: configRelPath === "phpstan.neon" ? null : configRelPath,
  });

  const notes = [];

  if (!composer) notes.push("No composer.json found; PHPStan is usually installed via Composer.");
  if (phpstanConfigFiles.length === 0) notes.push("No phpstan.neon or phpstan.neon.dist found at repo root.");
  if (!binaryRelPath && phpstanScripts.length === 0) notes.push("No PHPStan entrypoint detected (Composer script or vendor/bin/phpstan).");

  const stubSet = new Set(deps.stubs);
  const hasWordpressStubs = stubSet.has("php-stubs/wordpress-stubs");

  if (configHints && hasWordpressStubs && !configHints.mentionsWordpressStubs) {
    notes.push(
      "php-stubs/wordpress-stubs is installed but the PHPStan config does not mention wordpress-stubs. Ensure stubs are loaded via scanDirectories/scanFiles."
    );
  }

  if (configHints && !hasWordpressStubs && configHints.mentionsWordpressStubs) {
    notes.push(
      "PHPStan config mentions wordpress-stubs but the package was not found in Composer dependencies. Ensure php-stubs/wordpress-stubs is installed or paths are correct."
    );
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
        stubs: [...new Set(deps.stubs)].sort(),
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
