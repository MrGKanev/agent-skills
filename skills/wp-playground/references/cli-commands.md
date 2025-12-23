## Playground CLI command cheatsheet

> Requires Node.js 20.18+ and npm/npx.

### Install / run server

- `npx @wp-playground/cli@latest server [--port=9400] [--auto-mount] [--wp=<ver>] [--php=<ver>] [--verbosity=debug] [--blueprint=<url-or-path>]`
- Mounts:
  - `--auto-mount` (detect plugin/theme in CWD)
  - `--mount=/abs/host:/vfs/path` (repeatable)
  - `--mount-before-install` (apply mounts before WP install)

### Run a blueprint

- `npx @wp-playground/cli@latest run-blueprint --blueprint=<file-or-url> [--blueprint-may-read-adjacent-files] [--wp=<ver>] [--php=<ver>] [--verbosity=debug]`
- Use for scripted setup; no persistent server.

### Build a snapshot

- `npx @wp-playground/cli@latest build-snapshot --blueprint=<file-or-url> --outfile=./site.zip [--verbosity=debug]`
- Produces a sharable ZIP usable by Playground UI or other CLI commands.

### Debugging flags

- `--xdebug` / `--enable-xdebug` (depends on release) to start Xdebug listener.
- `--experimental-multi-worker` to speed multi-step blueprints; disable if unstable.

### Version control

- `--wp=<version>` to pick WordPress version (defaults to latest).
- `--php=<version>` to pick PHP version (defaults typically 8.3).
