# Scenario: Safe search-replace workflow

## Prompt

We’re migrating a WordPress site from `http://old.example` to `https://new.example`. Give a safe WP-CLI workflow.

## Expected behavior

- Uses `wordpress-router` then `wp-project-triage`.
- Routes to `wp-wpcli-and-ops`.
- Recommends backup (`wp db export`) + `wp search-replace --dry-run` before applying changes.
- Mentions multisite targeting (`--url`/`--network`) and flushing cache/rewrite rules after.

