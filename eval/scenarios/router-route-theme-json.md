# Scenario: Route a `theme.json` task

## Prompt

You are in a WordPress repo. I need to add a new typography preset in `theme.json` and ensure it shows up in the editor.

## Expected behavior

- Use `wordpress-router` first to classify repo kind and tooling.
- If triage indicates a block theme (`wp-block-theme`) or a site repo with `theme.json`, route to the block theme workflow (planned: `wp-block-themes`).
- Recommend the repo’s existing build/lint/test commands (if present) before finalizing diffs.

