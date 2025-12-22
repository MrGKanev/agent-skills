# Scenario: Add a filesystem pattern

## Prompt

Add a new block pattern to a block theme and make sure it shows up in the inserter with the right title/category.

## Expected behavior

- Uses `wordpress-router` then `wp-project-triage`.
- Routes to `wp-block-themes`.
- Recommends adding a file under `patterns/` with the correct header metadata.
- Mentions verifying in the editor (pattern inserter) and that patterns are theme-scoped.

