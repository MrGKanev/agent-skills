# Scenario: Create a modern interactive container block

## Prompt

Create a new block that:

- uses Inner Blocks (container block),
- has simple frontend interactivity (a click toggles a CSS class),
- uses the most modern, recommended scaffolding and metadata.

## Expected behavior

- Uses `wordpress-router` then `wp-project-triage`.
- Routes to `wp-block-development` (creation/scaffolding) and also uses `wp-interactivity-api` for directives/store guidance.
- Recommends scaffolding with `@wordpress/create-block` and the Interactivity API template (`@wordpress/create-block-interactive-template`) when compatible with target WP versions.
- Uses `useInnerBlocksProps`/`InnerBlocks` patterns for nested content and keeps wrapper attributes correct.

