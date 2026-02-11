require "./adapter"
require "../runtime"
require "../raw"

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
  # - Crystal compile should include `-Dlvgl_use_test` to enable these bindings.
  class HeadlessTestBackend
    include Adapter

    @display : Pointer(LibLvgl::LvDisplayT) = Pointer(LibLvgl::LvDisplayT).null

    def key : String
      "headless"
    end

    def available? : Bool
      {% if flag?(:lvgl_use_test) %}
        true
      {% else %}
        false
      {% end %}
    end

    def unavailable_reason : String?
      return nil if available?

      "Headless test backend requires LVGL test-module symbols; run `./scripts/build_lvgl_headless_test.sh` then `crystal spec -Dlvgl_use_test`."
    end

    def setup! : Nil
      raise unavailable_reason || "headless backend unavailable" unless available?

      Lvgl::Runtime.start
      {% if flag?(:lvgl_use_test) %}
        @display = LibLvgl.lv_test_display_create(480, 320)
        LibLvgl.lv_test_indev_create_all
      {% end %}
    end

    def teardown! : Nil
      return unless available?
      return if @display.null?

      {% if flag?(:lvgl_use_test) %}
        LibLvgl.lv_test_indev_delete_all
      {% end %}
      @display = Pointer(LibLvgl::LvDisplayT).null
    end
  end
end
