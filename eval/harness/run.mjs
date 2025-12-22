import fs from "node:fs";
import path from "node:path";
import { spawnSync } from "node:child_process";

function readUtf8(filePath) {
  return fs.readFileSync(filePath, "utf8");
}

function listSkillDirs(repoRoot) {
  const skillsRoot = path.join(repoRoot, "skills");
  if (!fs.existsSync(skillsRoot)) return [];
  return fs
    .readdirSync(skillsRoot, { withFileTypes: true })
    .filter((d) => d.isDirectory())
    .map((d) => path.join(skillsRoot, d.name));
}

function parseFrontmatter(markdown) {
  const match = markdown.match(/^---\n([\s\S]*?)\n---\n/);
  if (!match) return null;
  const yaml = match[1];
  const name = yaml.match(/^\s*name:\s*(.+)\s*$/m)?.[1]?.trim();
  const description = yaml.match(/^\s*description:\s*(.+)\s*$/m)?.[1]?.trim();
  return { name: name ?? null, description: description ?? null };
}

function assert(condition, message) {
  if (!condition) throw new Error(message);
}

function runJsonCommand(command, args, cwd) {
  const out = spawnSync(command, args, { cwd, encoding: "utf8" });
  if (out.status !== 0) {
    throw new Error(`Command failed: ${command} ${args.join(" ")}\n${out.stderr || out.stdout}`);
  }
  const text = out.stdout.trim();
  try {
    return JSON.parse(text);
  } catch {
    throw new Error(`Expected JSON output from: ${command} ${args.join(" ")}\nGot:\n${text.slice(0, 1000)}`);
  }
}

function main() {
  const repoRoot = process.cwd();

  const skillDirs = listSkillDirs(repoRoot);
  assert(skillDirs.length > 0, "No skills found under ./skills");

  for (const dir of skillDirs) {
    const skillPath = path.join(dir, "SKILL.md");
    assert(fs.existsSync(skillPath), `Missing SKILL.md: ${path.relative(repoRoot, skillPath)}`);
    const md = readUtf8(skillPath);
    const fm = parseFrontmatter(md);
    assert(fm, `Missing YAML frontmatter in: ${path.relative(repoRoot, skillPath)}`);
    assert(fm.name, `Missing frontmatter 'name' in: ${path.relative(repoRoot, skillPath)}`);
    assert(fm.description, `Missing frontmatter 'description' in: ${path.relative(repoRoot, skillPath)}`);

    const expectedName = path.basename(dir);
    assert(
      fm.name === expectedName,
      `Frontmatter name mismatch in ${path.relative(repoRoot, skillPath)}: expected '${expectedName}', got '${fm.name}'`
    );
  }

  const triageScript = path.join(repoRoot, "skills", "wp-project-triage", "scripts", "detect_wp_project.mjs");
  assert(fs.existsSync(triageScript), "Missing triage detector script");

  const report = runJsonCommand("node", [triageScript], repoRoot);
  assert(report?.tool?.name === "detect_wp_project", "Triage report missing tool.name");
  assert(Array.isArray(report?.project?.kind), "Triage report missing project.kind[]");
  assert(report?.signals?.paths?.repoRoot, "Triage report missing signals.paths.repoRoot");
  assert(report?.tooling?.php && report?.tooling?.node && report?.tooling?.tests, "Triage report missing tooling blocks");

  process.stdout.write("OK: skills frontmatter and triage report sanity checks passed.\n");
}

main();

