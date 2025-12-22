# Scenario: Add uninstall cleanup

## Prompt

Ensure the plugin removes its options on uninstall but does not delete data on deactivation.

## Expected behavior

- Uses `wordpress-router` then `wp-project-triage`.
- Routes to `wp-plugin-development`.
- Recommends adding `uninstall.php` (or `register_uninstall_hook`) and checking `WP_UNINSTALL_PLUGIN`.
- Ensures deactivation only performs lightweight cleanup (and does not delete stored data by default).

