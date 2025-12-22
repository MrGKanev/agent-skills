# Scenario: Multisite targeting guardrails

## Prompt

This is a multisite. I need to update one site’s `home` option without changing the whole network. How should I run WP-CLI?

## Expected behavior

- Uses `wordpress-router` then `wp-project-triage`.
- Routes to `wp-wpcli-and-ops`.
- Requires `--url=<site-url>` (site-scoped), and warns against network-wide operations when not intended.

