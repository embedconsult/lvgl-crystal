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

    # Combine a part with a state selector.
    def |(other : Lvgl::State) : Lvgl::StyleSelector
      Lvgl.style_selector(part: self, state: other)
    end
  end

  # LVGL object state flags used in style selectors.
  enum State : UInt32
    Default = 0x0000
    Pressed = 0x0020

    # Combine two state flags into one style selector mask.
    def |(other : Lvgl::State) : Lvgl::StyleSelector
      Lvgl::StyleSelector.new(to_i.to_u32 | other.to_i.to_u32)
    end

    # Combine state and part into one style selector.
    def |(other : Lvgl::Part) : Lvgl::StyleSelector
      Lvgl.style_selector(part: other, state: self)
    end
  end

  # LVGL background gradient direction values.
  enum GradDir : Int32
    None = 0
    Ver  = 1
    Hor  = 2
  end

  # LVGL blending modes.
  #
  # Source: [lv_style.h (`lv_blend_mode_t`)](https://github.com/embedconsult/lvgl/blob/v9.4.0/src/misc/lv_style.h).
  enum BlendMode : Int32
    Normal      = 0
    Additive    = 1
    Subtractive = 2
    Multiply    = 3
    Difference  = 4
  end

  # LVGL text decoration flags.
  #
  # Source: [lv_style.h (`lv_text_decor_t`)](https://github.com/embedconsult/lvgl/blob/v9.4.0/src/misc/lv_style.h).
  enum TextDecor : Int32
    None          = 0x00
    Underline     = 0x01
    Strikethrough = 0x02
  end

  # LVGL text alignment values.
  #
  # Source: [lv_text.h (`lv_text_align_t`)](https://github.com/embedconsult/lvgl/blob/v9.4.0/src/misc/lv_text.h).
  enum TextAlign : Int32
    Auto   = 0
    Left   = 1
    Center = 2
    Right  = 3
  end

  # LVGL border side flags.
  #
  # Source: [lv_style.h (`lv_border_side_t`)](https://github.com/embedconsult/lvgl/blob/v9.4.0/src/misc/lv_style.h).
  enum BorderSide : Int32
    None     = 0x00
    Bottom   = 0x01
    Top      = 0x02
    Left     = 0x04
    Right    = 0x08
    Full     = 0x0F
    Internal = 0x10
  end

  # LVGL base direction values.
  #
  # Source: [lv_bidi.h (`lv_base_dir_t`)](https://github.com/embedconsult/lvgl/blob/v9.4.0/src/misc/lv_bidi.h).
  enum BaseDirection : Int32
    Ltr     = 0x00
    Rtl     = 0x01
    Auto    = 0x02
    Neutral = 0x20
    Weak    = 0x21
  end

  # LVGL flex align values.
  #
  # Source: [lv_flex.h (`lv_flex_align_t`)](https://github.com/embedconsult/lvgl/blob/v9.4.0/src/layouts/flex/lv_flex.h).
  enum FlexAlign : Int32
    Start        = 0
    End          = 1
    Center       = 2
    SpaceEvenly  = 3
    SpaceAround  = 4
    SpaceBetween = 5
  end

  # LVGL flex flow values.
  #
  # Source: [lv_flex.h (`lv_flex_flow_t`)](https://github.com/embedconsult/lvgl/blob/v9.4.0/src/layouts/flex/lv_flex.h).
  enum FlexFlow : Int32
    Row               = 0x00
    Column            = 0x01
    RowWrap           = 0x04
    RowReverse        = 0x08
    RowWrapReverse    = 0x0C
    ColumnWrap        = 0x05
    ColumnReverse     = 0x09
    ColumnWrapReverse = 0x0D
  end

  # LVGL grid align values.
  #
  # Source: [lv_grid.h (`lv_grid_align_t`)](https://github.com/embedconsult/lvgl/blob/v9.4.0/src/layouts/grid/lv_grid.h).
  enum GridAlign : Int32
    Start        = 0
    Center       = 1
    End          = 2
    Stretch      = 3
    SpaceEvenly  = 4
    SpaceAround  = 5
    SpaceBetween = 6
  end

  # Crystal-friendly gradient direction aliases.
  enum GradientDirection : Int32
    None       = 0
    Vertical   = 1
    Horizontal = 2

    # Converts Crystal gradient direction aliases to LVGL gradient direction values.
    def to_grad_dir : Lvgl::GradDir
      case self
      when None
        Lvgl::GradDir::None
      when Vertical
        Lvgl::GradDir::Ver
      when Horizontal
        Lvgl::GradDir::Hor
      else
        raise "Unsupported gradient direction: #{self}"
      end
    end
  end

  # Common LVGL opacity presets.
  enum Opa : UInt8
    Transparent =   0
    P20         =  51
    Cover       = 255
  end

  # Crystal-friendly opacity alias.
  alias Opacity = Opa

  # Common radius presets.
  enum Radius : Int32
    Circle = 0x7fff
  end

  # LVGL style property IDs (`lv_style_prop_t`).
  #
  # Source: [lv_style.h (`_lv_style_id_t`)](https://github.com/embedconsult/lvgl/blob/v9.4.0/src/misc/lv_style.h).
  enum StyleProp : UInt8
    BgColor = 28
  end

  # Built-in LVGL Material palettes.
  enum Palette : Int32
    Red  =  0
    Grey = 18

    # Returns the palette primary color.
    def main : Lvgl::Color
      Lvgl::Color.new(LibLvgl.lv_palette_main(to_i))
    end

    # Returns a lightened color from this palette.
    def lighten(level : Int) : Lvgl::Color
      Lvgl::Color.new(LibLvgl.lv_palette_lighten(to_i, level.to_u8))
    end

    # Returns a darkened color from this palette.
    def darken(level : Int) : Lvgl::Color
      Lvgl::Color.new(LibLvgl.lv_palette_darken(to_i, level.to_u8))
    end
  end

  # Lightweight wrapper over `lv_style_selector_t`.
  #
  # Selector values combine `Lvgl::Part` and `Lvgl::State` bitmasks.
  struct StyleSelector
    # Create a selector from an already combined LVGL part/state bitmask.
    def initialize(@raw : UInt32)
    end

    # Returns the wrapped raw LVGL value for FFI calls.
    def to_unsafe : UInt32
      @raw
    end

    def |(other : Lvgl::State) : StyleSelector
      StyleSelector.new(@raw | other.to_i.to_u32)
    end

    def |(other : Lvgl::Part) : StyleSelector
      StyleSelector.new(@raw | other.to_i.to_u32)
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

    # Convenience black color (`0x000000`).
    def self.black : self
      hex(0x000000)
    end

    # Return a darkened variant of this color.
    def darken(level : Lvgl::Opa | UInt8 = Lvgl::Opa::P20) : self
      value = level.is_a?(Lvgl::Opa) ? level.to_i.to_u8 : level
      self.class.new(LibLvgl.lv_color_darken(@raw, value))
    end

    # Return the raw `lv_color_t` value for FFI calls.
    def to_unsafe : LibLvgl::LvColorT
      @raw
    end
  end
end
