# lvgl-crystal

Crystal project scaffold for building **LVGL GUI examples** on a **Debian Linux** target.

This repository is intended as a practical starting point for:

- experimenting with LVGL concepts in Crystal,
- building small GUI demos and widgets,
- validating Linux framebuffer/SDL-style integration strategies,
- and documenting reproducible Debian setup steps.

## Project Goals

- Keep example code small and easy to run.
- Provide a repeatable Debian setup for contributors.
- Make it straightforward to add new GUI examples under a consistent structure.

## Requirements

- Debian 12+ (or compatible Debian-based distro)
- Crystal 1.10+ (or newer)
- Git
- LVGL source and any display/input backends required for your target runtime

## Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/embedconsult/lvgl-crystal.git
   cd lvgl-crystal
   ```

2. Install Crystal (Debian package or official install script).

3. Install project dependencies:

   ```bash
   shards install
   ```

4. Prepare LVGL and backend libraries for your Debian target.

> Note: exact LVGL binding and backend wiring depends on your selected strategy
> (native C bindings, generated bindings, or wrapper shard).

## Usage

Run the app entry point:

```bash
crystal run src/lvgl-crystal.cr
```

Build the default shard target:

```bash
shards build
```

## Suggested Example Layout

As you add demos, keep examples organized by topic:

```text
src/
  lvgl-crystal.cr
  examples/
    basics/
    widgets/
    animations/
```

## Debian Notes for LVGL Targets

Typical Linux dependencies you may need (adjust for your backend):

```bash
sudo apt-get update
sudo apt-get install -y build-essential pkg-config libsdl2-dev
```

For framebuffer or DRM/KMS targets, install the corresponding development
packages and grant the required runtime permissions.

## Runtime Ownership Model

- Use a **single-owner fiber** model for LVGL calls whenever possible.
- `Lvgl::Object`/widget constructors auto-start runtime on first use (`Lvgl::Runtime.start`, idempotent).
- Prefer deterministic cleanup with `Lvgl::Runtime.shutdown` during app teardown.
- Treat direct `LibLvgl.lv_init` / `LibLvgl.lv_deinit` calls as low-level escape hatches.

Minimal lifecycle example (auto-start via first object):

```crystal
root = Lvgl::Object.new(nil)
# ... create and manipulate widgets from the same UI fiber ...
Lvgl::Runtime.shutdown
```

If your app prefers explicit bring-up, calling `Lvgl::Runtime.start` before
creating objects is still safe and idempotent.


## Backend Adapter Profiles

The Crystal bindings now expose backend adapter profiles under `src/lvgl/backend/`:

- `HeadlessTestBackend` (default for specs/CI)
- `SdlBackend` (placeholder profile)
- `WaylandBackend` (placeholder profile)

`LVGL_BACKEND` selects the profile (`headless` by default).

### Headless test backend (Debian-first)

This repository is pinned to LVGL shard version **9.4.0**, and the CI headless path uses the
**9.4 test-module APIs** from the source headers:

- `lib/lvgl/src/others/test/lv_test_display.h` (`lv_test_display_create`)
- `lib/lvgl/src/others/test/lv_test_indev.h` (`lv_test_indev_create_all`, `lv_test_indev_delete_all`)

Docs cross-reference used during implementation:

- 9.4 auxiliary test module index: https://docs.lvgl.io/9.4/details/auxiliary-modules/test/index.html
- master test docs (newer branch, not the pinned API baseline):
  https://docs.lvgl.io/master/details/auxiliary-modules/test/index.html

To run headless runtime specs in CI-like Debian environments, enable LVGL test symbols in the
shared library:

```bash
sudo apt-get update
sudo apt-get install -y build-essential clang lld pkg-config

shards install
# ./scripts/build_lvgl_headless_test.sh (Now part of the default build)
crystal spec
```

If test-module symbols are not available in the shared LVGL build (`-DLV_USE_TEST=1`),
runtime-dependent specs are skipped with a clear reason from `spec/support/lvgl_harness.cr`.

SDL and Wayland backends are follow-up runtime profiles and currently placeholders.

## Development

Run specs:

```bash
crystal spec
```

Format Crystal code:

```bash
crystal tool format
```


Generate API documentation locally:

```bash
crystal docs
```


## CI/CD

- **GitHub Actions** validates formatting/specs, builds binary artifacts, and publishes docs to GitHub Pages from `main`.
- **GitLab CI/CD** validates formatting/specs, stores binary artifacts, and publishes docs using the `pages` job from the default branch.

## Contributing

1. Create a feature branch.
2. Add or update one example at a time.
3. Include run instructions for every new example.
4. Run `crystal spec` and `crystal tool format` before submitting.

## Contributors

- [Jason Kridner](https://github.com/jadonk)
- Codex (project bootstrap assistant)
