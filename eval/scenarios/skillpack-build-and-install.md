# Scenario: Build and install skillpacks

## Prompt

Package this repo’s skills for Codex and VS Code and install them into another repository.

## Expected behavior

- Builds:
  - `node shared/scripts/skillpack-build.mjs --clean --targets=codex,vscode`
- Installs:
  - `node shared/scripts/skillpack-install.mjs --from=dist --dest=<repo-root> --targets=codex,vscode`
- Ensures there are no symlinks in installed skills.

