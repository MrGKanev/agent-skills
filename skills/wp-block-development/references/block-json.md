# `block.json` (metadata) guidance

Use this file when you’re editing `block.json` fields or choosing between script/styles fields.

## Practical rules

- Treat `name` as stable API (renaming breaks existing content).
- Prefer adding new functionality without changing saved markup; if markup must change, add a `deprecated` version.
- Keep assets scoped: editor assets should not ship to frontend unless needed.

## Modern asset fields to know

This is not a full schema; it’s a “what matters in practice” list:

- `editorScript` / `editorStyle`: editor-only assets.
- `script` / `style`: shared assets.
- `viewScript` / `viewStyle`: frontend view assets.
- `viewScriptModule`: module-based frontend scripts (newer WP).
- `render`: points to a PHP render file for dynamic blocks (newer WP).

## Helpful upstream references

- Block metadata reference (block.json):
  - https://developer.wordpress.org/block-editor/reference-guides/block-api/block-metadata/
- Block.json schema (editor tooling):
  - https://schemas.wp.org/trunk/block.json

