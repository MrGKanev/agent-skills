# Scenario: Triage output contract

## Prompt

Run the WordPress project triage and summarize what kind of repo this is and what commands to run first.

## Expected behavior

- Use `wp-project-triage` to run:
  - `node skills/wp-project-triage/scripts/detect_wp_project.mjs`
- Confirm the JSON includes at least:
  - `project.kind` and `project.primary`
  - `signals` with discovered paths and key signals
  - `tooling` (php/node/tests)
  - `recommendations.commands`

