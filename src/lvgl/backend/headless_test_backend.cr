require "./adapter"
require "../runtime"
require "../raw"
require "compiler/crystal/loader"

module Lvgl::Backend
  # Headless LVGL backend intended for CI test runs.
  #
  # LVGL source references used for this adapter:
  # - Pinned 9.4 source header: `lib/lvgl/src/others/test/lv_test_display.h`
  # - Pinned 9.4 source header: `lib/lvgl/src/others/test/lv_test_indev.h`
  #
  # Docs reference note:
  # - 9.4 auxiliary test module docs describe the stable feature family used here.
  # - master docs have newer prose, but this repository pins the LVGL shard at 9.4.0,
  #   so the implementation follows the 9.4 source tree above.
  #
  # Build requirements:
  # - LVGL shared lib must be compiled with `-DLV_USE_TEST=1`.
  class HeadlessTestBackend
    include Adapter

    @display : Pointer(LibLvgl::LvDisplayT) = Pointer(LibLvgl::LvDisplayT).null
    @test_symbols_available : Bool?

    # Backend selection key used by `Lvgl::Backend.from_env`.
    def key : String
      "headless"
    end

    # Returns `true` when the loaded `liblvgl.so` exports the required headless
    # test symbols (`lv_test_display_create`, `lv_test_indev_create_all`,
    # `lv_test_indev_delete_all`).
    #
    # This is `false` when LVGL was built without `LV_USE_TEST=1`.
    def available? : Bool
      @test_symbols_available ||= begin
        loader = ::Crystal::Loader.new([test_lib_dir])

        if loader.load_file?(test_lib_path)
          TEST_SYMBOLS.all? { |symbol| loader.find_symbol?(symbol) }
        else
          false
        end
      rescue
        false
      end
    end

    # Returns actionable guidance when headless test symbols are missing.
    def unavailable_reason : String?
      return nil if available?

      "Headless test backend requires LVGL test-module symbols; run `./scripts/build_lvgl_headless_test.sh` to rebuild liblvgl with LV_USE_TEST enabled."
    end

    # Starts LVGL runtime, creates a test display, and creates test input
    # devices (mouse/keypad/encoder).
    #
    # Raises when required symbols are unavailable.
    def setup! : Nil
      raise unavailable_reason || "headless backend unavailable" unless available?

      Lvgl::Runtime.start
      @display = LibLvgl.lv_test_display_create(480, 320)
      LibLvgl.lv_test_indev_create_all
    end

    # Deletes test input devices created by `setup!` and clears display handle.
    def teardown! : Nil
      return unless available?
      return if @display.null?

      LibLvgl.lv_test_indev_delete_all
      @display = Pointer(LibLvgl::LvDisplayT).null
    end

    private TEST_SYMBOLS = {
      "lv_test_display_create",
      "lv_test_indev_create_all",
      "lv_test_indev_delete_all",
    }

    private def test_lib_path : String
      Path[__DIR__, "../../../lib/lvgl/build/crystal/liblvgl.so"].expand.to_s
    end

    private def test_lib_dir : String
      File.dirname(test_lib_path)
    end
  end
end
