# Scenario: Add a style variation

## Prompt

Add a new style variation to a block theme and explain why an existing site might not reflect changes immediately.

## Expected behavior

- Uses `wordpress-router` then `wp-project-triage`.
- Routes to `wp-block-themes`.
- Recommends adding a JSON file under `styles/`.
- Notes that the selected variation is stored in the DB, so updates may require resetting user customizations or testing on a fresh site.

