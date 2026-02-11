require "./backend/adapter"
require "./backend/headless_test_backend"
require "./backend/sdl_backend"
require "./backend/wayland_backend"

module Lvgl::Backend
  def self.from_env : Adapter
    case ENV.fetch("LVGL_BACKEND", "headless").downcase
    when "headless", "headless_test", "ci"
      HeadlessTestBackend.new
    when "sdl"
      SdlBackend.new
    when "wayland"
      WaylandBackend.new
    else
      HeadlessTestBackend.new
    end
  end
end
