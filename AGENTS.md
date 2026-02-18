# AGENTS.md

Guidance for agents and contributors working in this repository.

## Scope

These instructions apply to the full repository tree.

## Project Intent

This is a Crystal project focused on creating and running **LVGL GUI examples**
on **Debian Linux** targets.

Primary priorities:

1. Keep examples concise and educational.
2. Keep Debian setup and run instructions reproducible.

## Tech and Conventions

- Language: Crystal
- Dependency manager: `shards`
- Test command: `crystal spec`
- Formatting command: `crystal tool format`

### Code style

- Follow Crystal style conventions and keep methods readable.
- Name examples by behavior (`button_toggle`, `list_navigation`) rather than by ticket IDs.
- Avoid introducing unnecessary abstractions in example code.

## Repository Layout Guidance

- Keep executable entry points in `src/`.
- Place reusable helpers in `src/` under clear module namespaces.
- Place example-specific logic under `src/examples/` grouped by topic.
- Keep specs in `spec/` mirroring source structure where practical.

## LVGL / Debian Guidance

When adding LVGL-related examples:

- Document backend assumptions (SDL, framebuffer, DRM/KMS, etc.).
- Mention required Debian packages in README updates.
- Keep platform-specific flags isolated and documented.

## LVGL Binding Wrappers

- Treat each `LibLvgl.lv_*` symbol as having one canonical Crystal wrapper method.
- Reuse that wrapper from other files instead of calling `LibLvgl` directly from multiple places.
- If a new raw LVGL call is required, add/extend the canonical wrapper first, then use it.

## Change Checklist

Before finishing a task, run:

```bash
crystal tool format
crystal spec
```

If runtime-specific features prevent execution in the current environment,
implement tests where possible and mark them pending/skipped in environments
where they cannot run, then document why.

## Documentation Requirements

For any user-facing change:

- Update `README.md` if setup, build, or run steps changed.
- Provide minimal copy-paste commands.
- Keep instructions Debian-first unless asked otherwise.

## Crystal-First Patterns (Agent Reminder)

- Prefer Crystal annotations and macros for compile-time registries/metadata instead of handwritten manifests.
- When metadata belongs to a type, place it on the type with `@[Annotation(...)]` and collect it via macro expansion.
- Prefer validation scripts/specs that read Crystal-generated structures directly over scripts that shell out to other scripts.
- Avoid scripts that rewrite source files when Crystal compile-time generation/verification can enforce consistency.

## Public Method Coverage Policy

All newly introduced public methods in `src/lvgl.cr` and `src/lvgl/**/*.cr` must have at least one corresponding reference in `spec/**/*.cr`.

If a method cannot be meaningfully spec-covered in this environment, add an explicit entry with justification to `spec/public_method_coverage_exemptions.txt`.

The CI/public-method coverage check (`scripts/check_public_method_spec_coverage.cr`) must pass before merging.

