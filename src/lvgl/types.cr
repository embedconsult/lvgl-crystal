require "./raw"

# Core LVGL enums and lightweight value wrappers.
module Lvgl
  alias Button = Widgets::Button
  alias Label = Widgets::Label
  alias Slider = Widgets::Slider

  # LVGL alignment values used by `lv_obj_align`.
  #
  # Source: [lv_area.h (`lv_align_t`)](https://github.com/embedconsult/lvgl/blob/v9.4.0/src/misc/lv_area.h).
  enum Align : Int32
    # `LV_ALIGN_CENTER` in LVGL (`lv_align_t`).
    Center = 9
  end

  # LVGL part selectors used by style setters.
  #
  # Source: [lv_obj_style.h (`lv_part_t`)](https://github.com/embedconsult/lvgl/blob/v9.4.0/src/core/lv_obj_style.h).
  enum Part : UInt32
    # `LV_PART_MAIN` in LVGL (`lv_part_t`).
    Main = 0x000000
  end

  # LVGL object state flags used in style selectors.
  enum State : UInt32
    Default = 0x0000
    Pressed = 0x0020
  end

  # LVGL background gradient direction values.
  enum GradDir : Int32
    None = 0
    Ver  = 1
    Hor  = 2
  end

  # Common LVGL opacity presets.
  enum Opa : UInt8
    Transparent =   0
    P20         =  51
    Cover       = 255
  end

  # Built-in LVGL Material palettes.
  enum Palette : Int32
    Red  =  0
    Grey = 18

    def main : Lvgl::Color
      Lvgl::Color.new(LibLvgl.lv_palette_main(to_i))
    end

    def lighten(level : Int) : Lvgl::Color
      Lvgl::Color.new(LibLvgl.lv_palette_lighten(to_i, level.to_u8))
    end

    def darken(level : Int) : Lvgl::Color
      Lvgl::Color.new(LibLvgl.lv_palette_darken(to_i, level.to_u8))
    end
  end

  # Lightweight wrapper over `lv_style_selector_t`.
  #
  # Selector values combine `Lvgl::Part` and `Lvgl::State` bitmasks.
  struct StyleSelector
    def initialize(@raw : UInt32)
    end

    def to_unsafe : UInt32
      @raw
    end
  end

  # Build a style selector bitmask from part and state.
  def self.style_selector(part : Part = Part::Main, state : State = State::Default) : StyleSelector
    StyleSelector.new(part.to_i.to_u32 | state.to_i.to_u32)
  end

  # LVGL color format values used by snapshot helpers.
  #
  # Source: [lv_color.h (`lv_color_format_t`)](https://github.com/embedconsult/lvgl/blob/v9.4.0/src/misc/lv_color.h).
  enum ColorFormat : UInt32
    # `LV_COLOR_FORMAT_ARGB8888` in LVGL (`lv_color_format_t`).
    Argb8888 = 0x10
    Xrgb8888 = 0x11
  end

  # LVGL generic result enum values for utility and snapshot APIs.
  #
  # Source: [lv_types.h (`lv_result_t`)](https://github.com/embedconsult/lvgl/blob/v9.4.0/src/misc/lv_types.h).
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

    # Return a darkened variant of this color.
    def darken(level : Lvgl::Opa | UInt8) : self
      value = level.is_a?(Lvgl::Opa) ? level.to_i.to_u8 : level
      self.class.new(LibLvgl.lv_color_darken(@raw, value))
    end

    # Return the raw `lv_color_t` value for FFI calls.
    def to_unsafe : LibLvgl::LvColorT
      @raw
    end
  end
end
