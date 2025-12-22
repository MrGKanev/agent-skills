# Scenario: Route and debug an Interactivity API issue

## Prompt

My block uses `data-wp-interactive` and `data-wp-on--click`, but clicks don’t do anything on the frontend. How do I debug this repo?

## Expected behavior

- Use `wordpress-router` then `wp-project-triage`.
- Route to `wp-interactivity-api`.
- Recommend searching for `data-wp-interactive`, `@wordpress/interactivity`, and `viewScriptModule`.
- Provide a debugging checklist: confirm view script module loads, confirm store namespace matches, check console errors, and scope interactivity.

