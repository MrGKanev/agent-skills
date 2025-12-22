# Scenario: Profile a slow endpoint (backend-only)

## Prompt

The site’s homepage TTFB is slow. Give me a backend-only profiling plan and what commands to run.

## Expected behavior

- Uses `wordpress-router` then `wp-project-triage`.
- Routes to `wp-performance`.
- Prefers `wp doctor check` first, then `wp profile stage` → `wp profile hook`.
- Mentions Query Monitor as optional and explains how to use it via REST headers/envelope (no browser).

