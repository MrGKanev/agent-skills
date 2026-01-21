# Agent Skills Collection

A curated collection of AI agent skills for efficient development workflows. Includes safety hooks to prevent destructive commands.

## Features

- **Skills**: Reusable knowledge packs for AI coding assistants
- **Safety Hooks**: Blocks destructive git commands (`git reset --hard`, `git push --force`, etc.)
- **Multi-platform**: Works with Claude Code, GitHub Copilot, and Cursor

## Installation

### One-liner (recommended)

```bash
# For Claude Code (global) - includes safety hooks
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

### Install from local repo

If you've cloned this repository and have custom skills in `my-skills/`, use `--local` to install directly from your local copy:

```bash
# Clone the repo
git clone https://github.com/MrGKanev/agent-skills.git
cd agent-skills

# Install from local (includes my-skills/)
./install.sh --local

# Preview what will be installed
./install.sh --local --list
```

This is useful when:
- You have custom skills in `my-skills/` that aren't pushed to GitHub
- You want to test changes before committing
- You're developing new skills locally

### Add shell alias (optional)

```bash
# Add 'claud' alias for 'claude --dangerously-skip-permissions'
curl -fsSL https://raw.githubusercontent.com/MrGKanev/agent-skills/master/install.sh | bash -s -- --alias
```

This adds `alias claud="claude --dangerously-skip-permissions"` to your shell config (`.zshrc` or `.bashrc`). After installation, restart your terminal or run `source ~/.zshrc` to use it. Only works with Claude Code target.

### List available skills

```bash
curl -fsSL https://raw.githubusercontent.com/MrGKanev/agent-skills/master/install.sh | bash -s -- --list
```

## What Gets Installed

| Target | Skills | Safety |
|--------|--------|--------|
| Claude Code | `~/.claude/skills/` | `~/.claude/hooks/` (blocks commands) |
| GitHub Copilot | `~/.github/skills/` | `copilot-instructions.md` (text rules) |
| Cursor | `~/.cursor/skills/` | `.cursor/rules/` (text rules) |

> **Note**: Only Claude Code has real protection via executable hooks. Copilot and Cursor receive text-based guidelines that the AI may not always follow.

## Safety Hooks

The installer includes a safety hook that blocks destructive commands before they execute.

**Blocked commands:**
- `git reset --hard` - destroys uncommitted changes
- `git checkout -- .` - discards all changes
- `git clean -f` - removes untracked files
- `git push --force` - overwrites remote history
- `git branch -D` - force deletes branches
- `rm -rf` on project directories

**Safe alternatives suggested:**
- Use `git stash` before destructive operations
- Use `git clean --dry-run` to preview
- Use `git push --force-with-lease` instead of `--force`

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

### Research & Academic Writing

| Skill | Description |
|-------|-------------|
| `academic-writing` | Academic manuscript preparation and formatting |
| `grant-writing` | Grant proposal writing assistance |
| `hypothesis-dev` | Research hypothesis development |
| `lit-review` | Systematic literature review methodology |
| `manuscript-review` | Peer review and manuscript feedback |
| `paper-search` | Academic paper discovery and search |
| `reference-management` | Citation and bibliography management |

### Development Workflow

| Skill | Description |
|-------|-------------|
| `ask-questions-if-underspecified` | Clarify requirements before implementing |
| `avoid-feature-creep` | Prevent scope creep, stay focused on MVP |

### Marketing & CRO (from coreyhaines31)

| Skill | Description |
|-------|-------------|
| `ab-test-setup` | Plan and implement A/B tests |
| `analytics-tracking` | Set up tracking and measurement |
| `competitor-alternatives` | Competitor comparison and alternative pages |
| `copy-editing` | Edit and polish existing copy |
| `copywriting` | Write or improve marketing copy |
| `email-sequence` | Build email sequences and drip campaigns |
| `form-cro` | Optimize lead capture and contact forms |
| `free-tool-strategy` | Plan engineering-as-marketing tools |
| `launch-strategy` | Product launches and feature announcements |
| `marketing-ideas` | 140 SaaS marketing ideas and strategies |
| `marketing-psychology` | 70+ mental models for marketing |
| `onboarding-cro` | Improve user activation and onboarding |
| `page-cro` | Conversion optimization for any marketing page |
| `paid-ads` | Create and optimize paid ad campaigns |
| `paywall-upgrade-cro` | In-app paywalls and upgrade screens |
| `popup-cro` | Create/optimize popups and modals |
| `pricing-strategy` | Design pricing, packaging, and monetization |
| `programmatic-seo` | Build SEO pages at scale |
| `referral-program` | Design referral and affiliate programs |
| `schema-markup` | Add structured data and rich snippets |
| `seo-audit` | Audit technical and on-page SEO |
| `signup-flow-cro` | Optimize signup and registration flows |
| `social-content` | Create and schedule social media content |

### SEO & AI Marketing

| Skill | Description |
|-------|-------------|
| `aeo` | Answer Engine Optimization - optimize content for AI assistant recommendations (ChatGPT, Perplexity, Claude, Gemini) |

## Local Development

If you clone this repo, you can use `skills-manage.sh` to manage skills and evals locally.

### Quick Start

```bash
# Clone and install locally (includes your custom my-skills/)
git clone https://github.com/MrGKanev/agent-skills.git
cd agent-skills
./install.sh --local
```

### Directory Structure

```
agent-skills/
├── skills/          # Upstream skills (from Automattic, etc.)
├── my-skills/       # Your custom skills (not synced upstream)
├── hooks/           # Safety hooks for Claude Code
├── install.sh       # Installer script
└── skills-manage.sh # Management script
```

**Note**: `my-skills/` is for your personal/custom skills. These are installed with `--local` but won't be included when others install via curl from GitHub (unless you push them).

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

## Sources & Attribution

All original authors retain their rights. See [CREDITS.md](CREDITS.md) for details.

| Source | License | Skills |
|--------|---------|--------|
| [Automattic](https://github.com/Automattic/agent-skills) | MIT | WordPress development skills |
| [coreyhaines31](https://github.com/coreyhaines31/marketingskills) | MIT | Marketing & CRO skills |

## License

This repository is a collection. Each skill retains its original license.
See [CREDITS.md](CREDITS.md) and individual LICENSE files for details.
