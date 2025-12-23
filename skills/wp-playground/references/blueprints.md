## Blueprint quick reference

Blueprints are JSON recipes that describe how Playground should set up WordPress.

### Minimal example

```json
{
  "$schema": "https://playground.wordpress.net/blueprint-schema.json",
  "steps": [
    { "step": "installTheme", "themeZipUrl": "https://downloads.wordpress.org/theme/twentytwentythree.zip" },
    { "step": "installPlugin", "pluginZipUrl": "https://downloads.wordpress.org/plugin/classic-editor.zip" }
  ]
}
```

### Common steps (non-exhaustive)

- `setSiteUrl`, `setHomeUrl`
- `installTheme`, `installPlugin` (ZIP URLs or local paths when allowed)
- `activateTheme`, `activatePlugin`
- `runPHP` (inline PHP)
- `applyPatches` (filesystem patch)
- `writeFile` (create/update files)
- `importFile` (XML/WXR)
- `wpConfigConstants` (define constants)

### Tips

- Use `--blueprint-may-read-adjacent-files` when the blueprint needs local files (e.g., custom plugin ZIP) during `run-blueprint` or `build-snapshot`.
- For iterative authoring, keep blueprints small and compose via separate files.
- Validate against the published schema URL above to catch typos.
- For Gutenberg/nightly testing, set `--wp=<version>` to align with target WP.

