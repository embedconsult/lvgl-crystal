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
- Crystal 1.19.1 (or newer) with Shards
- Git

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

### Environment assumptions (Linux and macOS)

- `LVGL_BACKEND=headless` is wired and used by default in this repository.
- `LVGL_BACKEND=wayland` is wired when the Crystal app is built with
  `-Dlvgl_wayland` and `liblvgl.so` is built with native Wayland driver
  support (`LV_USE_WAYLAND=1`).
- Headless execution requires LVGL test-module symbols to exist in
  `lib/lvgl/build/crystal/liblvgl.so` (built with `-DLV_USE_TEST=1`).
- Runtime on Linux and macOS defaults to the headless test backend path unless
  you explicitly select a platform backend via `LVGL_BACKEND`.

On Linux (Debian/Ubuntu), build prerequisites:

```bash
sudo apt-get update
sudo apt-get install -y build-essential clang lld pkg-config
# Install Crystal 1.19.1 and Shards
```

On macOS (MacPorts), install equivalent toolchain prerequisites:

```bash
sudo port install crystal shards pkgconfig
```

### Generate reference images for documentation

```bash
LVGL_BACKEND=headless crystal run scripts/generate_example_images.cr -- all
```

Generated artifacts:

- `docs/images/*.png`

These generated images are intentionally not committed to the repository.

Build the default shard target:

```bash
shards build
```

## Suggested Example Layout

As you add demos, keep examples organized by topic:

```text
src/
  lvgl.cr
  lvgl/
    widgets/
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

For native Wayland backend builds (`LVGL_BACKEND=wayland`), include Wayland
client development libraries when building LVGL:

```bash
sudo apt-get update
sudo apt-get install -y libwayland-dev wayland-protocols libxkbcommon-dev
```

For framebuffer or DRM/KMS targets, install the corresponding development
packages and grant the required runtime permissions.

## Internal Runtime Ownership Model

If you follow the Applet pattern and don't make LVGL calls outside of the provided fibers, then
you should adhere to these requirements by default.

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


### LVGL Scheduler Concurrency Contract

`Lvgl::Scheduler` centralizes `lv_tick_inc` and `lv_timer_handler` behind one
UI event-loop helper.

- Only the **UI fiber** may call LVGL APIs or mutate LVGL objects/widgets.
- Background fibers must marshal UI changes with `scheduler.schedule { ... }`.
- The UI fiber periodically runs `scheduler.step` (or `drain_scheduled_work`,
  `tick_inc`, and `timer_handler` explicitly).

Minimal pattern:

```crystal
scheduler = Lvgl::Scheduler.new(
  tick_period_ms: Lvgl::Scheduler::DEFAULT_TICK_PERIOD_MS,
  max_sleep_ms: Lvgl::Scheduler::DEFAULT_MAX_SLEEP_MS,
)

# background fiber
spawn do
  scheduler.schedule do
    # safe: executed later on the UI fiber
    label.set_text("Updated from worker")
  end
end

# UI fiber loop
loop do
  sleep scheduler.step.milliseconds
end
```

If this ownership rule is violated and multiple fibers touch LVGL directly,
LVGL global/object state can race and produce undefined behavior including UI
corruption and hard crashes.

## Backend Adapter Profiles

The Crystal bindings now expose backend adapter profiles under `src/lvgl/backend/`:

- `HeadlessTestBackend` (default for specs/CI)
- `SdlBackend` (placeholder profile)
- `WaylandBackend` (native Wayland window/profile when LVGL is built with Wayland support)

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

SDL is still a follow-up runtime profile and remains a placeholder.
Wayland is wired to LVGL's native Wayland driver symbols and opens a real
Wayland window when built with `-Dlvgl_wayland` and those symbols are present
in `liblvgl.so`.
Wayland window size can be configured with `LVGL_WAYLAND_WIDTH` and
`LVGL_WAYLAND_HEIGHT` (defaults: `800x480`).

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
