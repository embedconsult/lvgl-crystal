# Documentation Style Guide

Use this format for API docs in `src/lvgl/*.cr` and `src/lvgl/widgets/*.cr`.
The goal is **thorough, self-contained docs** so readers can understand
available wrappers and behavior without opening external references first.

## Required section order

1. `## Summary`
2. `## Parameters` (when inputs exist)
3. `## Results` (when outputs/return values exist)
4. `## Example` (for user-facing classes and methods)
5. `## Links`

## Headings

- Use sentence-style headings exactly as listed above.
- Keep headings consistent so generated docs are easy to scan.
- Use additional sections (`## Notes`, `## Errors`, `## Threading`) only when needed.

## Parameter bullets

- Use one bullet per parameter: `- \`name\`: description`.
- Include units, defaults, and optional behavior.
- Call out ownership/lifetime rules for pointers and callback arguments.

## Results section

- Document return values and side effects.
- For nullable returns, explain when `nil` is expected.
- For mutating methods, state what LVGL object state changes.
- For methods returning `Nil`, focus Results on side effects and avoid redundant "returns Nil" phrasing.

## Examples

- Prefer copy-paste Crystal examples.
- Keep examples focused on one behavior.
- Prefer real wrappers (`Lvgl::Object`, `Lvgl::Widgets::Label`) over pseudo-code.

## Link style

- Always use Markdown links.
- `Source:` references must be Markdown links (not backticked file paths).
- Include both:
  - LVGL API docs links under `https://docs.lvgl.io/9.4/`.
  - LVGL source links to the embedconsult fork/tag when relevant, for example:
    `https://github.com/embedconsult/lvgl/blob/v9.4.0/...`.
- Prefer internal Crystal-doc links via backticked type names such as
  `Lvgl::Backend::Adapter` when referencing local APIs.

## Minimal template

```crystal
# One-line description.
#
# ## Summary
# Brief behavior and caveats.
#
# ## Parameters
# - `input`: What it controls.
#
# ## Results
# - Returns: what callers receive.
#
# ## Example
# ```crystal
# value = Example.call(input)
# ```
#
# ## Links
# - [LVGL API](https://docs.lvgl.io/9.4/...)
# - [LVGL source](https://github.com/embedconsult/lvgl/blob/v9.4.0/...)
```
