require "./adapter"
require "../runtime"
require "compiler/crystal/loader"
require "c/dlfcn"

module Lvgl::Backend
  # Native SDL runtime profile.
  #
  # This backend is detected at runtime by probing SDL driver symbols from the
  # currently loaded `liblvgl.so`.
  class SdlBackend
    include Adapter

    DEFAULT_WIDTH  = 800_i32
    DEFAULT_HEIGHT = 480_i32

    alias SdlWindowCreateProc = Int32, Int32 -> Pointer(LibLvgl::LvDisplayT)
    alias SdlWindowSetTitleProc = Pointer(LibLvgl::LvDisplayT), UInt8* ->
    alias SdlMouseCreateProc = -> Pointer(Void)
    alias SdlMousewheelCreateProc = -> Pointer(Void)
    alias SdlKeyboardCreateProc = -> Pointer(Void)
    alias SdlQuitProc = ->

    @display : Pointer(LibLvgl::LvDisplayT) = Pointer(LibLvgl::LvDisplayT).null
    @sdl_symbols_available : Bool?
    @window_title = "LVGL Crystal (SDL)"
    @dl_handle : Void* = Pointer(Void).null

    @sdl_window_create : SdlWindowCreateProc?
    @sdl_window_set_title : SdlWindowSetTitleProc?
    @sdl_mouse_create : SdlMouseCreateProc?
    @sdl_mousewheel_create : SdlMousewheelCreateProc?
    @sdl_keyboard_create : SdlKeyboardCreateProc?
    @sdl_quit : SdlQuitProc?

    def key : String
      "sdl"
    end

    def available? : Bool
      @sdl_symbols_available ||= load_sdl_symbols
    end

    def unavailable_reason : String?
      return nil if available?

      "SDL backend requires LVGL SDL driver symbols in #{lvgl_lib_path}; rebuild `liblvgl.so` with LV_USE_SDL=1 and SDL2 development libraries installed."
    end

    def setup! : Nil
      raise unavailable_reason || "SDL backend unavailable" unless available?

      Lvgl::Runtime.start
      @display = sdl_window_create.call(window_width, window_height)
      raise "SDL backend failed to create a window/display" if @display.null?

      sdl_window_set_title.call(@display, @window_title.to_unsafe)
      sdl_mouse_create.call
      sdl_mousewheel_create.call
      sdl_keyboard_create.call
    end

    def teardown! : Nil
      return unless available?

      sdl_quit.call
      @display = Pointer(LibLvgl::LvDisplayT).null
    end

    private REQUIRED_SDL_SYMBOLS = {
      "lv_sdl_window_create",
      "lv_sdl_window_set_title",
      "lv_sdl_mouse_create",
      "lv_sdl_mousewheel_create",
      "lv_sdl_keyboard_create",
      "lv_sdl_quit",
    }

    private def load_sdl_symbols : Bool
      loader = ::Crystal::Loader.new([lvgl_lib_dir])
      return false unless loader.load_file?(lvgl_lib_path)
      return false unless REQUIRED_SDL_SYMBOLS.all? { |symbol| loader.find_symbol?(symbol) }

      @dl_handle = LibC.dlopen(lvgl_lib_path, LibC::RTLD_LAZY | LibC::RTLD_GLOBAL)
      return false if @dl_handle.null?

      @sdl_window_create = load_proc("lv_sdl_window_create", SdlWindowCreateProc)
      @sdl_window_set_title = load_proc("lv_sdl_window_set_title", SdlWindowSetTitleProc)
      @sdl_mouse_create = load_proc("lv_sdl_mouse_create", SdlMouseCreateProc)
      @sdl_mousewheel_create = load_proc("lv_sdl_mousewheel_create", SdlMousewheelCreateProc)
      @sdl_keyboard_create = load_proc("lv_sdl_keyboard_create", SdlKeyboardCreateProc)
      @sdl_quit = load_proc("lv_sdl_quit", SdlQuitProc)

      !!(@sdl_window_create && @sdl_window_set_title && @sdl_mouse_create && @sdl_mousewheel_create && @sdl_keyboard_create && @sdl_quit)
    rescue
      false
    end

    private def load_proc(symbol_name : String, type : T.class) : T? forall T
      pointer = LibC.dlsym(@dl_handle, symbol_name)
      return nil if pointer.null?

      type.new(pointer, Pointer(Void).null)
    end

    private def sdl_window_create : SdlWindowCreateProc
      @sdl_window_create || raise "SDL window_create symbol not loaded"
    end

    private def sdl_window_set_title : SdlWindowSetTitleProc
      @sdl_window_set_title || raise "SDL window_set_title symbol not loaded"
    end

    private def sdl_mouse_create : SdlMouseCreateProc
      @sdl_mouse_create || raise "SDL mouse_create symbol not loaded"
    end

    private def sdl_mousewheel_create : SdlMousewheelCreateProc
      @sdl_mousewheel_create || raise "SDL mousewheel_create symbol not loaded"
    end

    private def sdl_keyboard_create : SdlKeyboardCreateProc
      @sdl_keyboard_create || raise "SDL keyboard_create symbol not loaded"
    end

    private def sdl_quit : SdlQuitProc
      @sdl_quit || raise "SDL quit symbol not loaded"
    end

    private def window_width : Int32
      ENV.fetch("LVGL_SDL_WIDTH", DEFAULT_WIDTH.to_s).to_i32
    rescue
      DEFAULT_WIDTH
    end

    private def window_height : Int32
      ENV.fetch("LVGL_SDL_HEIGHT", DEFAULT_HEIGHT.to_s).to_i32
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
