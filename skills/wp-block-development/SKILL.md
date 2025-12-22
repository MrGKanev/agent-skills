---
name: wp-block-development
description: Use when developing WordPress (Gutenberg) blocks: block.json metadata, register_block_type(_from_metadata), attributes/serialization, supports, dynamic rendering (render.php/render_callback), deprecations/migrations, viewScript vs viewScriptModule, and @wordpress/scripts/@wordpress/create-block build and test workflows.
---

# WP Block Development

## When to use

Use this skill for block work such as:

- creating a new block, or updating an existing one
- changing `block.json` (scripts/styles/supports/attributes/render/viewScriptModule)
- fixing “block invalid / not saving / attributes not persisting”
- adding dynamic rendering (`render.php` / `render_callback`)
- block deprecations and migrations (`deprecated` versions)
- build tooling for blocks (`@wordpress/scripts`, `@wordpress/create-block`, `wp-env`)

## Inputs required

- Repo root and target (plugin vs theme vs full site).
- The block name/namespace and where it lives (path to `block.json` if known).
- Target WordPress version range (especially if using modules / `viewScriptModule`).

## Procedure

### 0) Triage and locate blocks

1. Run triage:
   - `node skills/wp-project-triage/scripts/detect_wp_project.mjs`
2. List blocks (deterministic scan):
   - `node skills/wp-block-development/scripts/list_blocks.mjs`
3. Identify the block root (directory containing `block.json`) you’re changing.

If this repo is a full site (`wp-content/` present), be explicit about *which* plugin/theme contains the block.

### 1) Pick the right block model

- **Static block** (markup saved into post content): implement `save()`; keep attributes serialization stable.
- **Dynamic block** (server-rendered): use `render` in `block.json` (or `render_callback` in PHP) and keep `save()` minimal or `null`.
- **Interactive frontend behavior**:
  - Prefer `viewScriptModule` for modern module-based view scripts where supported.
  - If you’re working primarily on `data-wp-*` directives or stores, also use `wp-interactivity-api`.

### 2) Update `block.json` safely

Make changes in the block’s `block.json`, then confirm registration matches metadata.

For field-by-field guidance, read:
- `references/block-json.md`

Common pitfalls:

- changing `name` breaks compatibility (treat it as stable API)
- changing saved markup without adding `deprecated` causes “Invalid block”
- adding attributes without defining source/serialization correctly causes “attribute not saving”

### 3) Register the block (server-side preferred)

Prefer PHP registration using metadata, especially when:

- you need dynamic rendering
- you need translations (`wp_set_script_translations`)
- you need conditional asset loading

Read and apply:
- `references/registration.md`

### 4) Implement edit/save/render patterns

Follow wrapper attribute best practices:

- Editor: `useBlockProps()`
- Static save: `useBlockProps.save()`
- Dynamic render (PHP): `get_block_wrapper_attributes()`

Read:
- `references/supports-and-wrappers.md`
- `references/dynamic-rendering.md` (if dynamic)

### 5) Attributes and serialization

Before changing attributes:

- confirm where the attribute value lives (comment delimiter vs HTML vs context)
- avoid the deprecated `meta` attribute source

Read:
- `references/attributes-and-serialization.md`

### 6) Migrations and deprecations (avoid “Invalid block”)

If you change saved markup or attributes:

1. Add a `deprecated` entry (newest → oldest).
2. Provide `save` for old versions and an optional `migrate` to normalize attributes.

Read:
- `references/deprecations.md`

### 7) Tooling and verification commands

Prefer whatever the repo already uses:

- `@wordpress/scripts` (common) → run existing npm scripts
- `wp-env` (common) → use for local WP + E2E

Read:
- `references/tooling-and-testing.md`

## Verification

- Block appears in inserter and inserts successfully.
- Saving + reloading does not create “Invalid block”.
- Frontend output matches expectations (static: saved markup; dynamic: server output).
- Assets load where expected (editor vs frontend).
- Run the repo’s lint/build/tests that triage recommends.

## Failure modes / debugging

If something fails, start here:

- `references/debugging.md` (common failures + fastest checks)
- `references/attributes-and-serialization.md` (attributes not saving)
- `references/deprecations.md` (invalid block after change)

## Escalation

If you’re uncertain about upstream behavior/version support, consult canonical docs first:

- WordPress Developer Resources (Block Editor Handbook, Theme Handbook, Plugin Handbook)
- Gutenberg repo docs for bleeding-edge behaviors

