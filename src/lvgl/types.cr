require "./raw"

module Lvgl
  alias Button = Widgets::Button
  alias Label = Widgets::Label

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

  # LVGL color format values used by snapshot helpers.
  #
  # Source: `lib/lvgl/src/misc/lv_color.h` (`lv_color_format_t`).
  enum ColorFormat : UInt32
    # `LV_COLOR_FORMAT_ARGB8888` in LVGL (`lv_color_format_t`).
    Argb8888 = 0x10
    Xrgb8888 = 0x11
  end

  # LVGL generic result enum values for utility and snapshot APIs.
  #
  # Source: `lib/lvgl/src/misc/lv_types.h` (`lv_result_t`).
  enum Result : UInt32
    Invalid = 0
    Ok      = 1
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
