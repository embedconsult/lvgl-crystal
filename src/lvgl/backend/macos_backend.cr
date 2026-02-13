require "./adapter"
require "./sdl_backend"

module Lvgl::Backend
  # macOS runtime profile built on LVGL's SDL driver symbols.
  #
  # LVGL 9.4 in this repository does not ship a dedicated Cocoa driver API, so
  # this adapter reuses `SdlBackend` and provides a macOS-focused backend key.
  class MacosBackend
    include Adapter

    @sdl_backend = SdlBackend.new
    @previous_sdl_width : String?
    @previous_sdl_height : String?

    def key : String
      "macos"
    end

    def available? : Bool
      @sdl_backend.available?
    end

    def unavailable_reason : String?
      return nil if available?

      "macOS backend reuses LVGL SDL driver symbols in #{lvgl_lib_path}; rebuild `liblvgl.so` with LV_USE_SDL=1 and SDL2 development libraries installed."
    end

    def setup! : Nil
      apply_dimension_env_overrides
      @sdl_backend.setup!
    rescue ex
      restore_dimension_env
      raise ex
    end

    def teardown! : Nil
      @sdl_backend.teardown!
    ensure
      restore_dimension_env
    end

    private def apply_dimension_env_overrides : Nil
      @previous_sdl_width = ENV["LVGL_SDL_WIDTH"]?
      @previous_sdl_height = ENV["LVGL_SDL_HEIGHT"]?

      if (macos_width = ENV["LVGL_MACOS_WIDTH"]?) && ENV["LVGL_SDL_WIDTH"]?.nil?
        ENV["LVGL_SDL_WIDTH"] = macos_width
      end

      if (macos_height = ENV["LVGL_MACOS_HEIGHT"]?) && ENV["LVGL_SDL_HEIGHT"]?.nil?
        ENV["LVGL_SDL_HEIGHT"] = macos_height
      end
    end

    private def restore_dimension_env : Nil
      if (previous_width = @previous_sdl_width)
        ENV["LVGL_SDL_WIDTH"] = previous_width
      else
        ENV.delete("LVGL_SDL_WIDTH")
      end

      if (previous_height = @previous_sdl_height)
        ENV["LVGL_SDL_HEIGHT"] = previous_height
      else
        ENV.delete("LVGL_SDL_HEIGHT")
      end

      @previous_sdl_width = nil
      @previous_sdl_height = nil
    end

    private def lvgl_lib_path : String
      Path[__DIR__, "../../../lib/lvgl/build/crystal/liblvgl.so"].expand.to_s
    end
  end
end
