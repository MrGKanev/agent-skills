# Scenario: Add a settings page with Settings API

## Prompt

Add a new plugin setting (checkbox + text field) with a settings page, and make sure it’s secure and saves correctly.

## Expected behavior

- Uses `wordpress-router` then `wp-project-triage`.
- Routes to `wp-plugin-development`.
- Recommends Settings API (`register_setting`, `add_settings_field`) with sanitize callback.
- Enforces nonce + capability checks and proper output escaping.

