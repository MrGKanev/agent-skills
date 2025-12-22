# Scenario: Convert a static block to a dynamic block

## Prompt

Convert an existing static block to be server-rendered (dynamic) using a `render.php` file, without breaking existing content.

## Expected behavior

- Uses `wordpress-router` then `wp-project-triage`.
- Routes to `wp-block-development`.
- Recommends using `render` in `block.json` (or `render_callback`) and using `get_block_wrapper_attributes()` in PHP output.
- Calls out deprecations/migrations if saved markup or attribute shapes change.

