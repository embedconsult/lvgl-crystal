require "./adapter"
require "../runtime"
require "../raw"
require "compiler/crystal/loader"

module Lvgl::Backend
  # Native Wayland runtime profile.
  #
  # Build with `-Dlvgl_wayland` and an LVGL shared library compiled with
  # `LV_USE_WAYLAND=1` to enable windowed Wayland runtime behavior.
  class WaylandBackend
    include Adapter

    DEFAULT_WIDTH  = 800_u32
    DEFAULT_HEIGHT = 480_u32

    @display : Pointer(LibLvgl::LvDisplayT) = Pointer(LibLvgl::LvDisplayT).null
    @wayland_symbols_available : Bool?
    @window_title = "LVGL Crystal (Wayland)"

    def key : String
      "wayland"
    end

    def available? : Bool
      {% if flag?(:lvgl_wayland) %}
        @wayland_symbols_available ||= begin
          loader = ::Crystal::Loader.new([lvgl_lib_dir])

          if loader.load_file?(lvgl_lib_path)
            REQUIRED_WAYLAND_SYMBOLS.all? { |symbol| loader.find_symbol?(symbol) }
          else
            false
          end
        rescue
          false
        end
      {% else %}
        false
      {% end %}
    end

    def unavailable_reason : String?
      return nil if available?

      {% if flag?(:lvgl_wayland) %}
        "Wayland backend requires LVGL Wayland driver symbols in #{lvgl_lib_path}; rebuild liblvgl with LV_USE_WAYLAND=1 and required Wayland development libraries."
      {% else %}
        "Wayland backend was not compiled in; build with `-Dlvgl_wayland` and an LVGL shared library built with `LV_USE_WAYLAND=1`."
      {% end %}
    end

    def setup! : Nil
      raise unavailable_reason || "Wayland backend unavailable" unless available?

      {% if flag?(:lvgl_wayland) %}
        Lvgl::Runtime.start
        LibLvgl.lv_wayland_init
        @display = LibLvgl.lv_wayland_window_create(window_width, window_height, @window_title.to_unsafe, ->WaylandBackend.wayland_display_close(Pointer(LibLvgl::LvDisplayT)))
        raise "Wayland backend failed to create a window/display" if @display.null?

        Lvgl::Runtime.install_timer_handler do
          LibLvgl.lv_wayland_timer_handler
        end
      {% end %}
    end

    def teardown! : Nil
      Lvgl::Runtime.reset_timer_handler

      {% if flag?(:lvgl_wayland) %}
        return unless available?

        unless @display.null?
          LibLvgl.lv_wayland_window_close(@display) if LibLvgl.lv_wayland_window_is_open(@display)
          @display = Pointer(LibLvgl::LvDisplayT).null
        end

        LibLvgl.lv_wayland_deinit
      {% end %}
    end

    {% if flag?(:lvgl_wayland) %}
      protected def self.wayland_display_close(_display : Pointer(LibLvgl::LvDisplayT)) : Bool
        true
      end

      private REQUIRED_WAYLAND_SYMBOLS = {
        "lv_wayland_init",
        "lv_wayland_deinit",
        "lv_wayland_window_create",
        "lv_wayland_window_close",
        "lv_wayland_window_is_open",
        "lv_wayland_timer_handler",
      }

      private def window_width : UInt32
        ENV.fetch("LVGL_WAYLAND_WIDTH", DEFAULT_WIDTH.to_s).to_u32
      rescue
        DEFAULT_WIDTH
      end

      private def window_height : UInt32
        ENV.fetch("LVGL_WAYLAND_HEIGHT", DEFAULT_HEIGHT.to_s).to_u32
      rescue
        DEFAULT_HEIGHT
      end

      private def lvgl_lib_path : String
        Path[__DIR__, "../../../lib/lvgl/build/crystal/liblvgl.so"].expand.to_s
      end

      private def lvgl_lib_dir : String
        File.dirname(lvgl_lib_path)
      end
    {% end %}
  end
end
