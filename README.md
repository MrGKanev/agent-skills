# Agent Skills Collection

A curated collection of AI agent skills for efficient development workflows.

## Installation

### One-liner (recommended)

```bash
# For Claude Code (global)
curl -fsSL https://raw.githubusercontent.com/MrGKanev/agent-skills/master/install.sh | bash

# For GitHub Copilot
curl -fsSL https://raw.githubusercontent.com/MrGKanev/agent-skills/master/install.sh | bash -s -- --target=copilot

# For Cursor
curl -fsSL https://raw.githubusercontent.com/MrGKanev/agent-skills/master/install.sh | bash -s -- --target=cursor

# All targets at once
curl -fsSL https://raw.githubusercontent.com/MrGKanev/agent-skills/master/install.sh | bash -s -- --target=all
```

### Install to current project

```bash
# Install skills to current project (not global)
curl -fsSL https://raw.githubusercontent.com/MrGKanev/agent-skills/master/install.sh | bash -s -- --project

# With specific target
curl -fsSL https://raw.githubusercontent.com/MrGKanev/agent-skills/master/install.sh | bash -s -- --project --target=copilot
```

### Install specific version

```bash
# Install a specific release tag
curl -fsSL https://raw.githubusercontent.com/MrGKanev/agent-skills/master/install.sh | bash -s -- --tag=v1.0.0
```

### List available skills

```bash
curl -fsSL https://raw.githubusercontent.com/MrGKanev/agent-skills/master/install.sh | bash -s -- --list
```

## Where skills are installed

| Target | Global location | Project location |
|--------|-----------------|------------------|
| Claude Code | `~/.claude/skills/` | `.claude/skills/` |
| GitHub Copilot | `~/.github/skills/` | `.github/skills/` |
| Cursor | `~/.cursor/skills/` | `.cursor/skills/` |

## Available Skills

### WordPress Development (from Automattic)

| Skill | Description |
|-------|-------------|
| `wordpress-router` | Project classification and routing |
| `wp-project-triage` | Auto-detect project type and versions |
| `wp-block-development` | Gutenberg blocks, attributes, deprecations |
| `wp-block-themes` | Block themes, theme.json, patterns |
| `wp-plugin-development` | Plugin architecture, hooks, security |
| `wp-interactivity-api` | Frontend interactivity with data-wp-* |
| `wp-abilities-api` | Capabilities and REST authentication |
| `wp-wpcli-and-ops` | WP-CLI commands and automation |
| `wp-performance` | Profiling, caching, optimization |
| `wp-phpstan` | PHPStan static analysis |
| `wp-playground` | WordPress Playground environments |

## Local Development

If you clone this repo, you can use `skills-manage.sh` to manage skills and evals locally.

### Skills Management

```bash
# List all skills
./skills-manage.sh list

# Create a new custom skill
./skills-manage.sh new my-custom-skill

# Show skill info
./skills-manage.sh info wp-block-development

# Sync from upstream
./skills-manage.sh sync
```

### Evals (Test Scenarios)

Evals are JSON files that define test scenarios for skills.

```bash
# List all evals
./skills-manage.sh evals

# Create a new custom eval
./skills-manage.sh new-eval my-test-scenario

# Run eval validation
./skills-manage.sh run-evals
```

### Directory Structure

```
agent-skills/
├── skills/           # Upstream skills (don't edit directly)
├── my-skills/        # Your custom skills
├── eval/scenarios/   # Upstream eval scenarios
├── my-evals/         # Your custom eval scenarios
└── skills-manage.sh  # Management script
```

## Sources & Attribution

All original authors retain their rights. See [CREDITS.md](CREDITS.md) for details.

| Source | License | Repository |
|--------|---------|------------|
| Automattic | MIT | [agent-skills](https://github.com/Automattic/agent-skills) |

## License

This repository is a collection. Each skill retains its original license.
See [CREDITS.md](CREDITS.md) and individual LICENSE files for details.
