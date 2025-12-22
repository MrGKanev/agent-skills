# Scenario: Register an ability and expose it to REST

## Prompt

I want to add a new ability for my plugin feature and have the client UI check it via REST. What should I change?

## Expected behavior

- Use `wordpress-router` then `wp-project-triage`.
- Route to `wp-abilities-api`.
- Recommend registering the ability (and category if needed) and ensuring `meta.show_in_rest` is enabled.
- Mention the `wp-abilities/v1` REST namespace and verifying the endpoint returns the new ability.

