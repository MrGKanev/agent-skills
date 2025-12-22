# Scenario: Fix an admin action security issue

## Prompt

This plugin has an admin POST handler that checks a nonce but not user capabilities. Fix it.

## Expected behavior

- Uses `wordpress-router` then `wp-project-triage`.
- Routes to `wp-plugin-development`.
- Ensures nonce *and* capability checks are present.
- Sanitizes/validates input and escapes output appropriately.

