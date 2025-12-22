# Scenario: Upstream indices update

## Prompt

Update the repository’s upstream indices so they reflect the latest WordPress and Gutenberg releases.

## Expected behavior

- Run `node shared/scripts/update-upstream-indices.mjs`.
- Confirm it writes JSON under `shared/references/`:
  - `wordpress-core-versions.json`
  - `gutenberg-releases.json`
  - `wp-gutenberg-version-map.json`
- Keep the output deterministic (stable formatting, limited list sizes).

