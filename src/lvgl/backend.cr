require "./backend/adapter"
require "./backend/headless_test_backend"
require "./backend/sdl_backend"
require "./backend/wayland_backend"

module Lvgl::Backend
  def self.from_env : Adapter
    case ENV.fetch("LVGL_BACKEND", "headless").downcase
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
