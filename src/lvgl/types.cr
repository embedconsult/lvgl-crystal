require "./raw"

module Lvgl
  # LVGL alignment values used by `lv_obj_align`.
  #
  # Source: `lib/lvgl/src/misc/lv_area.h` (`lv_align_t`).
  enum Align : Int32
    # `LV_ALIGN_CENTER` in LVGL (`lv_align_t`).
    Center = 9
  end

  # LVGL part selectors used by style setters.
  #
  # Source: `lib/lvgl/src/core/lv_obj_style.h` (`lv_part_t`).
  enum Part : UInt32
    # `LV_PART_MAIN` in LVGL (`lv_part_t`).
    Main = 0x000000
  end

  # Lightweight wrapper over LVGL `lv_color_t` values.
  struct Color
    # Create a wrapper around an existing LVGL color value.
    def initialize(@raw : LibLvgl::LvColorT)
    end

    # Build a color from a 24-bit hex RGB value (`0xRRGGBB`).
    def self.hex(value : Int) : self
      new(LibLvgl.lv_color_hex(value.to_u32))
    end

    # Return the raw `lv_color_t` value for FFI calls.
    def to_unsafe : LibLvgl::LvColorT
      @raw
    end
  end
end
