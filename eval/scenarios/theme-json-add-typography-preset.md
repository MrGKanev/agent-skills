# Scenario: Add a typography preset via theme.json

## Prompt

Add a new typography preset in `theme.json` and ensure it shows up in the editor.

## Expected behavior

- Uses `wordpress-router` then `wp-project-triage`.
- Routes to `wp-block-themes`.
- Recommends locating the correct theme root and validating style hierarchy (user overrides).
- Updates `theme.json` under `settings.typography` (or equivalent) and verifies in Site Editor.

