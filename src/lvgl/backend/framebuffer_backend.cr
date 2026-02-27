require "./adapter"
require "../runtime"
require "compiler/crystal/loader"
require "c/dlfcn"

module Lvgl::Backend
  # Linux framebuffer runtime profile.
  #
  # This backend is detected at runtime by probing Linux fbdev/evdev driver
  # symbols from the currently loaded `liblvgl.so`.
  class FramebufferBackend
    include Adapter

    DEFAULT_FRAMEBUFFER_DEVICE = "/dev/fb0"
    DEFAULT_INPUT_DEVICE       = "/dev/input/event0"

    alias FbdevCreateProc = -> Pointer(LibLvgl::LvDisplayT)
    alias FbdevSetFileProc = Pointer(LibLvgl::LvDisplayT), UInt8* ->
    alias EvdevCreateProc = -> Pointer(Void)
    alias EvdevSetFileProc = Pointer(Void), UInt8* ->

    @display : Pointer(LibLvgl::LvDisplayT) = Pointer(LibLvgl::LvDisplayT).null
    @indev : Pointer(Void) = Pointer(Void).null
    @framebuffer_symbols_available : Bool?
    @dl_handle : Void* = Pointer(Void).null

    @fbdev_create : FbdevCreateProc?
    @fbdev_set_file : FbdevSetFileProc?
    @evdev_create : EvdevCreateProc?
    @evdev_set_file : EvdevSetFileProc?

    # Backend selection key used by `Lvgl::Backend.from_env`.
    def key : String
      "framebuffer"
    end

    # Returns `true` when `liblvgl.so` exports required fbdev/evdev symbols
    # and those symbols can be loaded via `dlopen`/`dlsym`.
    #
    # This is typically `false` when LVGL was not built with
    # `LV_USE_LINUX_FBDEV=1` and `LV_USE_EVDEV=1`.
    def available? : Bool
      @framebuffer_symbols_available ||= load_framebuffer_symbols
    end

    # Returns actionable guidance when framebuffer symbols are unavailable.
    def unavailable_reason : String?
      return nil if available?

      "Framebuffer backend requires LVGL Linux fbdev + evdev driver symbols in #{lvgl_lib_path}; rebuild `liblvgl.so` with LV_USE_LINUX_FBDEV=1 and LV_USE_EVDEV=1."
    end

    # Starts LVGL runtime, creates an fbdev-backed LVGL display, binds it to
    # `LVGL_FBDEV_DEVICE` (default `/dev/fb0`), and creates/binds an evdev input
    # device from `LVGL_EVDEV_DEVICE` (default `/dev/input/event0`).
    #
    # Raises when required symbols are unavailable or display creation fails.
    def setup! : Nil
      raise unavailable_reason || "Framebuffer backend unavailable" unless available?

      Lvgl::Runtime.start
      @display = fbdev_create.call
      raise "Framebuffer backend failed to create a display" if @display.null?

      fbdev_set_file.call(@display, framebuffer_device.to_unsafe)

      @indev = evdev_create.call
      raise "Framebuffer backend failed to create an input device" if @indev.null?

      evdev_set_file.call(@indev, input_device.to_unsafe)
    end

    # Clears cached display/input handles.
    #
    # The LVGL Linux fbdev/evdev drivers do not expose dedicated teardown
    # symbols in the same stable shape as setup, so this backend only resets the
    # tracked handles here.
    def teardown! : Nil
      @display = Pointer(LibLvgl::LvDisplayT).null
      @indev = Pointer(Void).null
    end

    private REQUIRED_FRAMEBUFFER_SYMBOLS = {
      "lv_linux_fbdev_create",
      "lv_linux_fbdev_set_file",
      "lv_evdev_create",
      "lv_evdev_set_file",
    }

    private def load_framebuffer_symbols : Bool
      loader = ::Crystal::Loader.new([lvgl_lib_dir])
      return false unless loader.load_file?(lvgl_lib_path)
      return false unless REQUIRED_FRAMEBUFFER_SYMBOLS.all? { |symbol| loader.find_symbol?(symbol) }

      @dl_handle = LibC.dlopen(lvgl_lib_path, LibC::RTLD_LAZY | LibC::RTLD_GLOBAL)
      return false if @dl_handle.null?

      @fbdev_create = load_proc("lv_linux_fbdev_create", FbdevCreateProc)
      @fbdev_set_file = load_proc("lv_linux_fbdev_set_file", FbdevSetFileProc)
      @evdev_create = load_proc("lv_evdev_create", EvdevCreateProc)
      @evdev_set_file = load_proc("lv_evdev_set_file", EvdevSetFileProc)

      !!(@fbdev_create && @fbdev_set_file && @evdev_create && @evdev_set_file)
    rescue
      false
    end

    private def load_proc(symbol_name : String, type : T.class) : T? forall T
      pointer = LibC.dlsym(@dl_handle, symbol_name)
      return nil if pointer.null?

      type.new(pointer, Pointer(Void).null)
    end

    private def fbdev_create : FbdevCreateProc
      @fbdev_create || raise "Framebuffer create symbol not loaded"
    end

    private def fbdev_set_file : FbdevSetFileProc
      @fbdev_set_file || raise "Framebuffer set_file symbol not loaded"
    end

    private def evdev_create : EvdevCreateProc
      @evdev_create || raise "Evdev create symbol not loaded"
    end

    private def evdev_set_file : EvdevSetFileProc
      @evdev_set_file || raise "Evdev set_file symbol not loaded"
    end

    private def framebuffer_device : String
      ENV.fetch("LVGL_FBDEV_DEVICE", DEFAULT_FRAMEBUFFER_DEVICE)
    end

    private def input_device : String
      ENV.fetch("LVGL_EVDEV_DEVICE", DEFAULT_INPUT_DEVICE)
    end

    private def lvgl_lib_path : String
      Path[__DIR__, "../../../lib/lvgl/build/crystal/liblvgl.so"].expand.to_s
    end

    private def lvgl_lib_dir : String
      File.dirname(lvgl_lib_path)
    end
  end
end
