require "./backend/adapter"
require "./backend/headless_test_backend"
require "./backend/sdl_backend"
require "./backend/wayland_backend"

# Backend selector for runtime adapter profiles.
#
# ## Summary
# Resolves `LVGL_BACKEND` to one supported adapter implementation.
#
# ## Example
# ```
# backend = Lvgl::Backend.from_env
# backend.setup!
# ```
#
# ## Links
# - [Backend adapter source](https://github.com/embedconsult/lvgl-crystal/blob/main/src/lvgl/backend/adapter.cr)
# - [README backend notes](../README.md)
module Lvgl::Backend
  # Selects a backend adapter using `LVGL_BACKEND`.
  #
  # ## Summary
  # Supports `headless`, `sdl`, and `wayland` values. Unknown values fall back
  # to `HeadlessTestBackend`.
  #
  # ## Results
  # - Returns: A concrete `Lvgl::Backend::Adapter` implementation.
  #
  # ## Links
  # - [Backend adapter source](https://github.com/embedconsult/lvgl-crystal/blob/main/src/lvgl/backend/adapter.cr)
  # - `Lvgl::Backend::Adapter`
  def self.from_env : Adapter
    case ENV.fetch("LVGL_BACKEND", "sdl").downcase
    when "headless", "headless_test", "ci"
      Log.debug { "Using Headless backend" }
      HeadlessTestBackend.new
    when "sdl"
      Log.debug { "Using SDL backend" }
      SdlBackend.new
    when "wayland"
      Log.debug { "Using Wayland backend" }
      WaylandBackend.new
    else
      Log.debug { "Using Headless (default) backend" }
      HeadlessTestBackend.new
    end
  end
end
