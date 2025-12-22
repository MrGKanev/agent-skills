# Scenario: Add a block attribute safely

## Prompt

Add a new attribute to an existing block and make sure existing content doesn’t become “Invalid block”.

## Expected behavior

- Uses `wordpress-router` then `wp-project-triage`.
- Routes to `wp-block-development`.
- Recommends inspecting the current `block.json`, `edit`, and `save` to understand serialization.
- If saved markup changes, recommends adding a `deprecated` version and (if needed) a migration path.

