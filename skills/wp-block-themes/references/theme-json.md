# `theme.json` guidance

Use this file when changing global settings/styles or per-block styling.

## High-level structure

Common top-level keys:

- `version`
- `settings` (what the UI exposes / allows)
- `styles` (default appearance)
- `customTemplates` and `templateParts` (optional, to describe templates and parts)

Upstream references:

- Theme Handbook: https://developer.wordpress.org/themes/global-settings-and-styles/
- Block Editor Handbook (often more current): https://developer.wordpress.org/block-editor/how-to-guides/themes/theme-json/

## Practical guardrails

- Prefer presets when you want editor-visible controls (colors, font sizes, spacing).
- Prefer `styles` when you want consistent defaults without requiring user choice.
- Be careful with specificity: user global styles override theme defaults.

