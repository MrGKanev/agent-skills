# Debugging quick routes

## Block doesn’t appear in inserter

- Confirm `block.json` `name` is valid and the block is registered.
- Confirm build output exists and scripts are enqueued.
- If using PHP registration, confirm `register_block_type_from_metadata()` runs (wrong hook/file not loaded is common).

## “This block contains unexpected or invalid content”

- You changed saved markup or attribute parsing.
- Add `deprecated` versions and a migration path.
- Reproduce with an old post containing the previous markup.

## Attributes not saving

- Confirm attribute definition matches actual markup.
- If the value is in delimiter JSON, avoid brittle selectors.
- Avoid `meta` attribute source (deprecated).

