# Debugging checklist

1. Confirm the interactive root exists in the rendered HTML (`data-wp-interactive`).
2. Confirm the view script module is loaded (network + source maps).
3. Confirm store namespace matches what markup expects.
4. Check console for errors before any interaction.
5. Reduce scope:
   - temporarily remove directives to isolate which directive/store path breaks.
6. If hydration mismatch occurs:
   - ensure initial state/context matches server markup.

