# Scenario: Diagnose autoloaded options bloat

## Prompt

Admin pages are slow and memory usage is high. Check whether autoloaded options are bloated and suggest a safe plan.

## Expected behavior

- Uses `wp-performance`.
- Uses `wp option list --autoload=on --format=total_bytes` and `size_bytes` sorting to identify large options.
- Mentions `wp doctor` autoload-options-size check as a quick signal.
- Proposes safe remediation (disable autoload, migrate blobs to cache, cautious deletion).

