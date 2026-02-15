require "./adapter"
require "../runtime"
require "compiler/crystal/loader"
require "c/dlfcn"

module Lvgl::Backend
  # Native Wayland runtime profile.
  #
  # This backend is detected at runtime by probing Wayland driver symbols from
  # the currently loaded `liblvgl.so`.
  class WaylandBackend
    include Adapter

    DEFAULT_WIDTH  = 800_u32
    DEFAULT_HEIGHT = 480_u32

    alias WaylandInitProc = ->
    alias WaylandDeinitProc = ->
    alias WaylandWindowCreateProc = UInt32, UInt32, UInt8*, WaylandDisplayCloseProc -> Pointer(LibLvgl::LvDisplayT)
    alias WaylandWindowCloseProc = Pointer(LibLvgl::LvDisplayT) ->
    alias WaylandWindowIsOpenProc = Pointer(LibLvgl::LvDisplayT) -> Bool
    alias WaylandTimerHandlerProc = -> UInt32
    alias WaylandDisplayCloseProc = Pointer(LibLvgl::LvDisplayT) -> Bool

    @display : Pointer(LibLvgl::LvDisplayT) = Pointer(LibLvgl::LvDisplayT).null
    @wayland_symbols_available : Bool?
    @window_title = "LVGL Crystal (Wayland)"
    @dl_handle : Void* = Pointer(Void).null

    @wayland_init : WaylandInitProc?
    @wayland_deinit : WaylandDeinitProc?
    @wayland_window_create : WaylandWindowCreateProc?
    @wayland_window_close : WaylandWindowCloseProc?
    @wayland_window_is_open : WaylandWindowIsOpenProc?
    @wayland_timer_handler : WaylandTimerHandlerProc?

    # Backend selection key used by `Lvgl::Backend.from_env`.
    def key : String
      "wayland"
    end

    # Returns `true` when `liblvgl.so` exports required Wayland driver symbols
    # and those symbols can be loaded via `dlopen`/`dlsym`.
    #
    # This is typically `false` when LVGL was not built with `LV_USE_WAYLAND=1`.
    def available? : Bool
      @wayland_symbols_available ||= load_wayland_symbols
    end

    # Returns actionable guidance when Wayland symbols are unavailable.
    def unavailable_reason : String?
      return nil if available?

      "Wayland backend requires LVGL Wayland driver symbols in #{lvgl_lib_path}; rebuild or swap `liblvgl.so` with `LV_USE_WAYLAND=1` and required Wayland development libraries."
    end

    # Starts LVGL runtime, initializes Wayland backend, creates a Wayland window
    # display, and installs the Wayland timer handler as runtime timer hook.
    #
    # Raises when required symbols are unavailable or display creation fails.
    def setup! : Nil
      raise unavailable_reason || "Wayland backend unavailable" unless available?

      Lvgl::Runtime.start
      wayland_init.call
      @display = wayland_window_create.call(window_width, window_height, @window_title.to_unsafe, ->WaylandBackend.wayland_display_close(Pointer(LibLvgl::LvDisplayT)))
      raise "Wayland backend failed to create a window/display" if @display.null?

      Lvgl::Runtime.install_timer_handler do
        wayland_timer_handler.call
      end
    end

    # Restores default runtime timer handling, closes active Wayland window (if
    # still open), and deinitializes Wayland backend resources.
    def teardown! : Nil
      Lvgl::Runtime.reset_timer_handler
      return unless available?

      unless @display.null?
        wayland_window_close.call(@display) if wayland_window_is_open.call(@display)
        @display = Pointer(LibLvgl::LvDisplayT).null
      end

      wayland_deinit.call
    end

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

    private def load_wayland_symbols : Bool
      loader = ::Crystal::Loader.new([lvgl_lib_dir])
      return false unless loader.load_file?(lvgl_lib_path)
      return false unless REQUIRED_WAYLAND_SYMBOLS.all? { |symbol| loader.find_symbol?(symbol) }

      @dl_handle = LibC.dlopen(lvgl_lib_path, LibC::RTLD_LAZY | LibC::RTLD_GLOBAL)
      return false if @dl_handle.null?

      @wayland_init = load_proc("lv_wayland_init", WaylandInitProc)
      @wayland_deinit = load_proc("lv_wayland_deinit", WaylandDeinitProc)
      @wayland_window_create = load_proc("lv_wayland_window_create", WaylandWindowCreateProc)
      @wayland_window_close = load_proc("lv_wayland_window_close", WaylandWindowCloseProc)
      @wayland_window_is_open = load_proc("lv_wayland_window_is_open", WaylandWindowIsOpenProc)
      @wayland_timer_handler = load_proc("lv_wayland_timer_handler", WaylandTimerHandlerProc)

      !!(@wayland_init && @wayland_deinit && @wayland_window_create && @wayland_window_close && @wayland_window_is_open && @wayland_timer_handler)
    rescue
      false
    end

    private def load_proc(symbol_name : String, type : T.class) : T? forall T
      pointer = LibC.dlsym(@dl_handle, symbol_name)
      return nil if pointer.null?

      type.new(pointer, Pointer(Void).null)
    end

    private def wayland_init : WaylandInitProc
      @wayland_init || raise "Wayland init symbol not loaded"
    end

    private def wayland_deinit : WaylandDeinitProc
      @wayland_deinit || raise "Wayland deinit symbol not loaded"
    end

    private def wayland_window_create : WaylandWindowCreateProc
      @wayland_window_create || raise "Wayland window_create symbol not loaded"
    end

    private def wayland_window_close : WaylandWindowCloseProc
      @wayland_window_close || raise "Wayland window_close symbol not loaded"
    end

    private def wayland_window_is_open : WaylandWindowIsOpenProc
      @wayland_window_is_open || raise "Wayland window_is_open symbol not loaded"
    end

    private def wayland_timer_handler : WaylandTimerHandlerProc
      @wayland_timer_handler || raise "Wayland timer_handler symbol not loaded"
    end

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
  end
end
