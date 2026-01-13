# Agent Skills Collection

A curated collection of AI agent skills for efficient development workflows.

## What is this?

This repository aggregates skills from various sources to create a comprehensive toolkit for AI coding assistants (Claude Code, Copilot, Cursor, etc.). Each skill teaches AI assistants specific patterns, best practices, and procedures.

## Structure

```
agent-skills/
├── skills/           # Third-party skills (synced from upstream sources)
├── my-skills/        # Custom skills
└── skills-manage.sh  # Management script
```

## Quick Start

```bash
# List all available skills
./skills-manage.sh list

# Sync with upstream sources
./skills-manage.sh sync

# Create a new custom skill
./skills-manage.sh new <skill-name>

# Show info about a skill
./skills-manage.sh info <skill-name>
```

## Sources & Attribution

This collection includes skills from the following sources. All original authors retain their rights.

| Source | Skills | License | Link |
|--------|--------|---------|------|
| **Automattic** | WordPress development skills (blocks, themes, plugins, WP-CLI, etc.) | MIT | [agent-skills](https://github.com/Automattic/agent-skills) |

### Automattic Skills (MIT License)

The following WordPress-focused skills are from Automattic's agent-skills repository:

- `wordpress-router` - Classifies WordPress repos and routes to the right workflow
- `wp-project-triage` - Detects project type, tooling, and versions
- `wp-block-development` - Gutenberg blocks, attributes, rendering, deprecations
- `wp-block-themes` - Block themes, theme.json, templates, patterns
- `wp-plugin-development` - Plugin architecture, hooks, settings API, security
- `wp-interactivity-api` - Frontend interactivity with data-wp-* directives
- `wp-abilities-api` - Capability-based permissions and REST API auth
- `wp-wpcli-and-ops` - WP-CLI commands, automation, multisite
- `wp-performance` - Profiling, caching, optimization
- `wp-phpstan` - PHPStan static analysis for WordPress
- `wp-playground` - WordPress Playground for local environments

## Adding New Sources

To add skills from another repository:

1. Add it as a git remote: `git remote add <name> <url>`
2. Fetch and merge: `git fetch <name> && git merge <name>/<branch>`
3. Update the attribution table in this README

## License

This repository is a collection. Each skill retains its original license:
- Automattic skills: MIT License
- Custom skills in `my-skills/`: MIT License (unless otherwise noted)

See individual skill directories for specific license information.
