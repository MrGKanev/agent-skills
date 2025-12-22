# PHP registration quick guide

Key concepts and entrypoints for the WordPress Abilities API:

- Register ability categories and abilities in PHP.
- Use the Abilities API init hooks to ensure registration occurs at the right lifecycle time:
  - `wp_abilities_api_init`
  - `wp_abilities_api_categories_init`

Common primitives to search for / use:

- `wp_register_ability_category( $category_id, $args )`
- `wp_register_ability( $ability_id, $args )`

Recommended patterns:

- Namespace IDs (e.g. `my-plugin:feature.edit`).
- Treat IDs as stable API; changing IDs is a breaking change.
- If client UIs need the ability, set:
  - `meta.show_in_rest = true`
- If ability is informational, set:
  - `meta.readonly = true`

