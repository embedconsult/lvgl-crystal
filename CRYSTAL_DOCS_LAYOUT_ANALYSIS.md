# Crystal Docs Layout and Gallery Customization Analysis

This document explains how `crystal docs` currently works in this repository,
what can and cannot be customized directly, and a practical plan to improve the
gallery overview layout (images + body text) without forking Crystal tooling.

## 1) How `crystal docs` works

`crystal docs` scans source files in `src/`, parses doc comments, and renders a
static documentation site.

## 2) Current customization surface

From `crystal docs --help`, practical knobs are:

- `--project-name`
- `--project-version`
- `--source-refname`
- `--source-url-pattern`
- `--output`
- `--format=html|json`
- `--canonical-base-url`
- sitemap options

The key point: these options customize metadata and output location, **not the
HTML theme/layout internals**.

## 3) What this means for layout work

Because the built-in HTML template is not configured in this repo, layout
control is primarily achieved through:

1. Better doc-comment structure and markdown.
2. Consistent metadata feeding generated docs sections.
3. Optional post-processing step over generated HTML.
4. Alternative generator flow from `--format=json`.

## 4) Repository-specific state

The docs gallery is generated from applet metadata (`@[Lvgl::ExampleMetadata]`)
and emitted under `Examples::DocsGallery` so entries appear in API docs.

This is a good design because:

- metadata remains close to each example,
- consistency checks already exist,
- image and source links can be validated in specs.

## 5) Recommended strategy for stronger gallery overview pages

### Level A (implemented now): improve metadata-driven body text

Add a required `summary` metadata field and render it in each generated gallery
entry doc block so every screenshot has explanatory body text.

Pros:

- no custom template maintenance,
- deterministic output in stock `crystal docs`,
- easy review in source control.

### Level B (next): generate a synthetic overview index method comment

Generate one method-level markdown section containing grouped lists/tables by
section (`Get Started`, `Widgets`) with title, summary, and image references.

### Level C (advanced): custom site from JSON output

Use `crystal docs --format=json` and build a dedicated gallery page with your
own static-site renderer for full card/grid control while preserving API docs.

## 6) Practical constraints and tradeoffs

- Full HTML/CSS theme replacement is not a first-class `crystal docs` flag.
- Keeping customization in source comments is robust and low-friction.
- JSON-based custom docs provide maximal control at the cost of maintenance.

## 7) Suggested command patterns

```bash
# stock docs build
crystal docs -o docs/api

# include repository metadata for source links
crystal docs \
  --project-name="lvgl-crystal" \
  --project-version="$(shards version 2>/dev/null || echo dev)" \
  --source-refname="$(git rev-parse --short HEAD)" \
  --source-url-pattern="https://github.com/embedconsult/lvgl-crystal/blob/%{refname}/%{path}#L%{line}" \
  -o docs/api
```

## 8) Decision guidance

If your goal is:

- **“Better overview content and image context quickly”** → stay metadata+
  markdown driven in source (Level A/B).
- **“Custom card/grid visual design and bespoke nav”** → consume JSON and build
  a custom docs front-end (Level C).

For this project, Level A/B is the best default due to CI simplicity and
maintainability.
