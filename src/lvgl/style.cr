require "./types"
require "weak_ref"

# Mutable style descriptor wrapper for LVGL 9.4 (`lv_style_t`).
#
# ## Summary
# `Lvgl::Style` exposes LVGL style properties through Crystal scopes with
# assignment (`foo =...`) and fluent chaining (`foo(...)`) patterns.
#
# The API is organized by LVGL intent:
# - `background`
# - `border`
# - `outline`
# - `shadow`
# - `line`
# - `arc`
# - `text` (plus `text.outline`)
# - `layout`, `flex`, `grid`
# - `transition`
# - `color.filter`
#
# ## Lifetime notes
# - This wrapper owns one mutable `lv_style_t`.
# - `reset` clears all previously set style properties and reinitializes the
#   descriptor for reuse.
# - For pointer-backed string sources (for example background/arc image source),
#   this wrapper retains passed strings for style lifetime so LVGL pointer
#   properties remain valid.
#
# ## Example
# ```
# style = Lvgl::Style.new
# style.radius(10)
#
# style.background
#   .opacity(Lvgl::Opacity::Cover)
#   .color(Lvgl::Palette::Grey.lighten(3))
#   .gradient_color(Lvgl::Palette::Grey.main)
#   .gradient_direction(Lvgl::GradientDirection::Vertical)
#
# style.border
#   .width(2)
#   .color(Lvgl::Color.black)
#   .opacity(Lvgl::Opacity::P20)
#
# # Inside an applet setup method where `button` is a widget:
# style.apply_to(button, selector: Lvgl::Part::Main | Lvgl::State::Default)
# style.apply_to(button, selector: Lvgl::Part::Main | Lvgl::State::Pressed)
# ```
#
# ## Links
# - [LVGL style API (9.4)](https://docs.lvgl.io/9.4/API/misc/lv_style_gen_h.html)
# - [LVGL style concepts (9.4)](https://docs.lvgl.io/9.4/overview/style.html)
# - [LVGL 9.4 style header](https://github.com/embedconsult/lvgl/blob/v9.4.0/src/misc/lv_style_gen.h)
class Lvgl::Style
  private alias SelectorInput = Lvgl::StyleSelector | Lvgl::State | Lvgl::Part | Int32 | UInt32
  private alias ColorFilterBlock = Lvgl::Style, Lvgl::Color, UInt8 -> Lvgl::Color

  @@color_filter_lock = Mutex.new
  @@color_filter_handlers = {} of UInt64 => Tuple(WeakRef(Lvgl::Style), ColorFilterBlock)
  @@color_filter_next_token = 1_u64

  # Background-related style properties.
  #
  # ## Properties
  # - Fill: `color`, `opacity`
  # - Gradient: `gradient_color`, `gradient_direction`,
  #   `gradient_main_stop`, `gradient_stop`,
  #   `gradient_main_opacity`, `gradient_opacity`
  # - Background image: `image_source`, `image_opacity`,
  #   `image_recolor`, `image_recolor_opacity`, `image_tiled`
  #
  # ## LVGL mapping
  # - `lv_style_set_bg_*`
  #
  # ## Example
  # ```
  # style.background
  #   .color(Lvgl::Palette::Grey.lighten(3))
  #   .opacity(Lvgl::Opacity::Cover)
  #   .gradient_color(Lvgl::Palette::Grey.main)
  #   .gradient_direction(Lvgl::GradientDirection::Vertical)
  # ```
  #
  # ## Links
  # - [LVGL docs: style bg properties (9.4)](https://docs.lvgl.io/9.4/API/misc/lv_style_gen_h.html)
  # - [LVGL 9.4 header](https://github.com/embedconsult/lvgl/blob/v9.4.0/src/misc/lv_style_gen.h)
  class BackgroundScope
    # Create a background-scope wrapper bound to one style instance.
    def initialize(@style : Lvgl::Style)
    end

    # Sets background fill opacity (0 = transparent, 255 = cover).
    def opacity=(value : Lvgl::Opa | UInt8) : UInt8
      @style.set_bg_opa(value)
      value.is_a?(Lvgl::Opa) ? value.to_i.to_u8 : value
    end

    # Chaining form of `opacity=`. Applies the same property and returns the same scope instance for further chained calls.
    def opacity(value : Lvgl::Opa | UInt8) : self
      self.opacity = value
      self
    end

    # Sets primary background fill color.
    def color=(value : Lvgl::Color) : Lvgl::Color
      @style.set_bg_color(value)
      value
    end

    # Chaining form of `color=`. Applies the same property and returns the same scope instance for further chained calls.
    def color(value : Lvgl::Color) : self
      self.color = value
      self
    end

    # Sets secondary background gradient color.
    def gradient_color=(value : Lvgl::Color) : Lvgl::Color
      @style.set_bg_grad_color(value)
      value
    end

    # Chaining form of `gradient_color=`. Applies the same property and returns the same scope instance for further chained calls.
    def gradient_color(value : Lvgl::Color) : self
      self.gradient_color = value
      self
    end

    # Sets background gradient direction.
    def gradient_direction=(value : Lvgl::GradDir | Lvgl::GradientDirection) : Lvgl::GradDir | Lvgl::GradientDirection
      @style.set_bg_grad_dir(value)
      value
    end

    # Chaining form of `gradient_direction=`. Applies the same property and returns the same scope instance for further chained calls.
    def gradient_direction(value : Lvgl::GradDir | Lvgl::GradientDirection) : self
      self.gradient_direction = value
      self
    end

    # Sets main gradient stop position (typically 0..255).
    def gradient_main_stop=(value : Int32) : Int32
      @style.set_bg_main_stop(value)
      value
    end

    # Chaining form of `gradient_main_stop=`. Applies the same property and returns the same scope instance for further chained calls.
    def gradient_main_stop(value : Int32) : self
      self.gradient_main_stop = value
      self
    end

    # Sets secondary gradient stop position (typically 0..255).
    def gradient_stop=(value : Int32) : Int32
      @style.set_bg_grad_stop(value)
      value
    end

    # Chaining form of `gradient_stop=`. Applies the same property and returns the same scope instance for further chained calls.
    def gradient_stop(value : Int32) : self
      self.gradient_stop = value
      self
    end

    # Sets opacity of the main gradient color.
    def gradient_main_opacity=(value : Lvgl::Opa | UInt8) : UInt8
      @style.set_bg_main_opa(value)
      value.is_a?(Lvgl::Opa) ? value.to_i.to_u8 : value
    end

    # Chaining form of `gradient_main_opacity=`. Applies the same property and returns the same scope instance for further chained calls.
    def gradient_main_opacity(value : Lvgl::Opa | UInt8) : self
      self.gradient_main_opacity = value
      self
    end

    # Sets opacity of the secondary gradient color.
    def gradient_opacity=(value : Lvgl::Opa | UInt8) : UInt8
      @style.set_bg_grad_opa(value)
      value.is_a?(Lvgl::Opa) ? value.to_i.to_u8 : value
    end

    # Chaining form of `gradient_opacity=`. Applies the same property and returns the same scope instance for further chained calls.
    def gradient_opacity(value : Lvgl::Opa | UInt8) : self
      self.gradient_opacity = value
      self
    end

    # Sets background image source as raw pointer or string-backed pointer.
    def image_source=(value : String | Pointer(Void)) : String | Pointer(Void)
      @style.set_bg_image_src(value)
      value
    end

    # Chaining form of `image_source=`. Applies the same property and returns the same scope instance for further chained calls.
    def image_source(value : String | Pointer(Void)) : self
      self.image_source = value
      self
    end

    # Sets background image opacity (0..255).
    def image_opacity=(value : Lvgl::Opa | UInt8) : UInt8
      @style.set_bg_image_opa(value)
      value.is_a?(Lvgl::Opa) ? value.to_i.to_u8 : value
    end

    # Chaining form of `image_opacity=`. Applies the same property and returns the same scope instance for further chained calls.
    def image_opacity(value : Lvgl::Opa | UInt8) : self
      self.image_opacity = value
      self
    end

    # Sets background image recolor.
    def image_recolor=(value : Lvgl::Color) : Lvgl::Color
      @style.set_bg_image_recolor(value)
      value
    end

    # Chaining form of `image_recolor=`. Applies the same property and returns the same scope instance for further chained calls.
    def image_recolor(value : Lvgl::Color) : self
      self.image_recolor = value
      self
    end

    # Sets background image recolor opacity.
    def image_recolor_opacity=(value : Lvgl::Opa | UInt8) : UInt8
      @style.set_bg_image_recolor_opa(value)
      value.is_a?(Lvgl::Opa) ? value.to_i.to_u8 : value
    end

    # Chaining form of `image_recolor_opacity=`. Applies the same property and returns the same scope instance for further chained calls.
    def image_recolor_opacity(value : Lvgl::Opa | UInt8) : self
      self.image_recolor_opacity = value
      self
    end

    # Enables or disables background image tiling.
    def image_tiled=(value : Bool) : Bool
      @style.set_bg_image_tiled(value)
      value
    end

    # Chaining form of `image_tiled=`. Applies the same property and returns the same scope instance for further chained calls.
    def image_tiled(value : Bool) : self
      self.image_tiled = value
      self
    end
  end

  # Border-related style properties.
  #
  # ## Properties
  # - `color`, `opacity`, `width`, `side`, `post`
  #
  # ## LVGL mapping
  # - `lv_style_set_border_*`
  #
  # ## Example
  # ```
  # style.border
  #   .width(2)
  #   .color(Lvgl::Color.black)
  #   .opacity(Lvgl::Opacity::P20)
  #   .side(Lvgl::BorderSide::Full)
  # ```
  #
  # ## Links
  # - [LVGL docs: border style properties (9.4)](https://docs.lvgl.io/9.4/API/misc/lv_style_gen_h.html)
  # - [LVGL 9.4 header](https://github.com/embedconsult/lvgl/blob/v9.4.0/src/misc/lv_style_gen.h)
  class BorderScope
    # Create a border-scope wrapper bound to one style instance.
    def initialize(@style : Lvgl::Style)
    end

    # Sets border color.
    def color=(value : Lvgl::Color) : Lvgl::Color
      @style.set_border_color(value)
      value
    end

    # Chaining form of `color=`. Applies the same property and returns the same scope instance for further chained calls.
    def color(value : Lvgl::Color) : self
      self.color = value
      self
    end

    # Sets border opacity (0..255).
    def opacity=(value : Lvgl::Opa | UInt8) : UInt8
      @style.set_border_opa(value)
      value.is_a?(Lvgl::Opa) ? value.to_i.to_u8 : value
    end

    # Chaining form of `opacity=`. Applies the same property and returns the same scope instance for further chained calls.
    def opacity(value : Lvgl::Opa | UInt8) : self
      self.opacity = value
      self
    end

    # Sets border width in pixels.
    def width=(value : Int32) : Int32
      @style.set_border_width(value)
      value
    end

    # Chaining form of `width=`. Applies the same property and returns the same scope instance for further chained calls.
    def width(value : Int32) : self
      self.width = value
      self
    end

    # Sets border side mask.
    def side=(value : Lvgl::BorderSide) : Lvgl::BorderSide
      @style.set_border_side(value)
      value
    end

    # Chaining form of `side=`. Applies the same property and returns the same scope instance for further chained calls.
    def side(value : Lvgl::BorderSide) : self
      self.side = value
      self
    end

    # Sets whether border is drawn in post layer.
    def post=(value : Bool) : Bool
      @style.set_border_post(value)
      value
    end

    # Chaining form of `post=`. Applies the same property and returns the same scope instance for further chained calls.
    def post(value : Bool) : self
      self.post = value
      self
    end
  end

  # Outline-related style properties.
  #
  # ## Properties
  # - `width`, `color`, `opacity`, `pad`
  #
  # ## LVGL mapping
  # - `lv_style_set_outline_*`
  #
  # ## Example
  # ```
  # style.outline
  #   .width(2)
  #   .pad(3)
  #   .color(Lvgl::Palette::Grey.main)
  #   .opacity(Lvgl::Opacity::P20)
  # ```
  #
  # ## Links
  # - [LVGL docs: outline style properties (9.4)](https://docs.lvgl.io/9.4/API/misc/lv_style_gen_h.html)
  # - [LVGL 9.4 header](https://github.com/embedconsult/lvgl/blob/v9.4.0/src/misc/lv_style_gen.h)
  class OutlineScope
    # Create an outline-scope wrapper bound to one style instance.
    def initialize(@style : Lvgl::Style)
    end

    # Sets outline width in pixels.
    def width=(value : Int32) : Int32
      @style.set_outline_width(value)
      value
    end

    # Chaining form of `width=`. Applies the same property and returns the same scope instance for further chained calls.
    def width(value : Int32) : self
      self.width = value
      self
    end

    # Sets outline color.
    def color=(value : Lvgl::Color) : Lvgl::Color
      @style.set_outline_color(value)
      value
    end

    # Chaining form of `color=`. Applies the same property and returns the same scope instance for further chained calls.
    def color(value : Lvgl::Color) : self
      self.color = value
      self
    end

    # Sets outline opacity (0..255).
    def opacity=(value : Lvgl::Opa | UInt8) : UInt8
      @style.set_outline_opa(value)
      value.is_a?(Lvgl::Opa) ? value.to_i.to_u8 : value
    end

    # Chaining form of `opacity=`. Applies the same property and returns the same scope instance for further chained calls.
    def opacity(value : Lvgl::Opa | UInt8) : self
      self.opacity = value
      self
    end

    # Sets outline padding from object bounds.
    def pad=(value : Int32) : Int32
      @style.set_outline_pad(value)
      value
    end

    # Chaining form of `pad=`. Applies the same property and returns the same scope instance for further chained calls.
    def pad(value : Int32) : self
      self.pad = value
      self
    end
  end

  # Shadow-related style properties.
  #
  # ## Properties
  # - `width`, `offset_x`, `offset_y`, `spread`, `color`, `opacity`
  #
  # ## LVGL mapping
  # - `lv_style_set_shadow_*`
  #
  # ## Example
  # ```
  # style.shadow
  #   .width(16)
  #   .offset_x(4)
  #   .offset_y(6)
  #   .spread(2)
  #   .color(Lvgl::Color.black)
  #   .opacity(Lvgl::Opacity::P20)
  # ```
  #
  # ## Links
  # - [LVGL docs: shadow style properties (9.4)](https://docs.lvgl.io/9.4/API/misc/lv_style_gen_h.html)
  # - [LVGL 9.4 header](https://github.com/embedconsult/lvgl/blob/v9.4.0/src/misc/lv_style_gen.h)
  class ShadowScope
    # Create a shadow-scope wrapper bound to one style instance.
    def initialize(@style : Lvgl::Style)
    end

    # Sets shadow blur width.
    def width=(value : Int32) : Int32
      @style.set_shadow_width(value)
      value
    end

    # Chaining form of `width=`. Applies the same property and returns the same scope instance for further chained calls.
    def width(value : Int32) : self
      self.width = value
      self
    end

    # Sets shadow horizontal offset.
    def offset_x=(value : Int32) : Int32
      @style.set_shadow_offset_x(value)
      value
    end

    # Chaining form of `offset_x=`. Applies the same property and returns the same scope instance for further chained calls.
    def offset_x(value : Int32) : self
      self.offset_x = value
      self
    end

    # Sets shadow vertical offset.
    def offset_y=(value : Int32) : Int32
      @style.set_shadow_offset_y(value)
      value
    end

    # Chaining form of `offset_y=`. Applies the same property and returns the same scope instance for further chained calls.
    def offset_y(value : Int32) : self
      self.offset_y = value
      self
    end

    # Sets shadow spread.
    def spread=(value : Int32) : Int32
      @style.set_shadow_spread(value)
      value
    end

    # Chaining form of `spread=`. Applies the same property and returns the same scope instance for further chained calls.
    def spread(value : Int32) : self
      self.spread = value
      self
    end

    # Sets shadow color.
    def color=(value : Lvgl::Color) : Lvgl::Color
      @style.set_shadow_color(value)
      value
    end

    # Chaining form of `color=`. Applies the same property and returns the same scope instance for further chained calls.
    def color(value : Lvgl::Color) : self
      self.color = value
      self
    end

    # Sets shadow opacity (0..255).
    def opacity=(value : Lvgl::Opa | UInt8) : UInt8
      @style.set_shadow_opa(value)
      value.is_a?(Lvgl::Opa) ? value.to_i.to_u8 : value
    end

    # Chaining form of `opacity=`. Applies the same property and returns the same scope instance for further chained calls.
    def opacity(value : Lvgl::Opa | UInt8) : self
      self.opacity = value
      self
    end
  end

  # Line-related style properties.
  #
  # ## Properties
  # - `width`, `dash_width`, `dash_gap`, `rounded`, `color`, `opacity`
  #
  # ## LVGL mapping
  # - `lv_style_set_line_*`
  #
  # ## Example
  # ```
  # style.line
  #   .width(3)
  #   .dash_width(8)
  #   .dash_gap(4)
  #   .rounded(true)
  #   .color(Lvgl::Color.black)
  #   .opacity(Lvgl::Opacity::Cover)
  # ```
  #
  # ## Links
  # - [LVGL docs: line style properties (9.4)](https://docs.lvgl.io/9.4/API/misc/lv_style_gen_h.html)
  # - [LVGL 9.4 header](https://github.com/embedconsult/lvgl/blob/v9.4.0/src/misc/lv_style_gen.h)
  class LineScope
    # Create a line-scope wrapper bound to one style instance.
    def initialize(@style : Lvgl::Style)
    end

    # Sets line width in pixels.
    def width=(value : Int32) : Int32
      @style.set_line_width(value)
      value
    end

    # Chaining form of `width=`. Applies the same property and returns the same scope instance for further chained calls.
    def width(value : Int32) : self
      self.width = value
      self
    end

    # Sets line dash segment width.
    def dash_width=(value : Int32) : Int32
      @style.set_line_dash_width(value)
      value
    end

    # Chaining form of `dash_width=`. Applies the same property and returns the same scope instance for further chained calls.
    def dash_width(value : Int32) : self
      self.dash_width = value
      self
    end

    # Sets line dash gap width.
    def dash_gap=(value : Int32) : Int32
      @style.set_line_dash_gap(value)
      value
    end

    # Chaining form of `dash_gap=`. Applies the same property and returns the same scope instance for further chained calls.
    def dash_gap(value : Int32) : self
      self.dash_gap = value
      self
    end

    # Enables or disables rounded line ends.
    def rounded=(value : Bool) : Bool
      @style.set_line_rounded(value)
      value
    end

    # Chaining form of `rounded=`. Applies the same property and returns the same scope instance for further chained calls.
    def rounded(value : Bool) : self
      self.rounded = value
      self
    end

    # Sets line color.
    def color=(value : Lvgl::Color) : Lvgl::Color
      @style.set_line_color(value)
      value
    end

    # Chaining form of `color=`. Applies the same property and returns the same scope instance for further chained calls.
    def color(value : Lvgl::Color) : self
      self.color = value
      self
    end

    # Sets line opacity (0..255).
    def opacity=(value : Lvgl::Opa | UInt8) : UInt8
      @style.set_line_opa(value)
      value.is_a?(Lvgl::Opa) ? value.to_i.to_u8 : value
    end

    # Chaining form of `opacity=`. Applies the same property and returns the same scope instance for further chained calls.
    def opacity(value : Lvgl::Opa | UInt8) : self
      self.opacity = value
      self
    end
  end

  # Arc-related style properties.
  #
  # ## Properties
  # - `width`, `rounded`, `color`, `opacity`, `image_source`
  #
  # ## LVGL mapping
  # - `lv_style_set_arc_*`
  #
  # ## Example
  # ```
  # style.arc
  #   .width(4)
  #   .rounded(true)
  #   .color(Lvgl::Palette::Red.main)
  #   .opacity(Lvgl::Opacity::Cover)
  # ```
  #
  # ## Links
  # - [LVGL docs: arc style properties (9.4)](https://docs.lvgl.io/9.4/API/misc/lv_style_gen_h.html)
  # - [LVGL 9.4 header](https://github.com/embedconsult/lvgl/blob/v9.4.0/src/misc/lv_style_gen.h)
  class ArcScope
    # Create an arc-scope wrapper bound to one style instance.
    def initialize(@style : Lvgl::Style)
    end

    # Sets arc width in pixels.
    def width=(value : Int32) : Int32
      @style.set_arc_width(value)
      value
    end

    # Chaining form of `width=`. Applies the same property and returns the same scope instance for further chained calls.
    def width(value : Int32) : self
      self.width = value
      self
    end

    # Enables or disables rounded arc ends.
    def rounded=(value : Bool) : Bool
      @style.set_arc_rounded(value)
      value
    end

    # Chaining form of `rounded=`. Applies the same property and returns the same scope instance for further chained calls.
    def rounded(value : Bool) : self
      self.rounded = value
      self
    end

    # Sets arc color.
    def color=(value : Lvgl::Color) : Lvgl::Color
      @style.set_arc_color(value)
      value
    end

    # Chaining form of `color=`. Applies the same property and returns the same scope instance for further chained calls.
    def color(value : Lvgl::Color) : self
      self.color = value
      self
    end

    # Sets arc opacity (0..255).
    def opacity=(value : Lvgl::Opa | UInt8) : UInt8
      @style.set_arc_opa(value)
      value.is_a?(Lvgl::Opa) ? value.to_i.to_u8 : value
    end

    # Chaining form of `opacity=`. Applies the same property and returns the same scope instance for further chained calls.
    def opacity(value : Lvgl::Opa | UInt8) : self
      self.opacity = value
      self
    end

    # Sets arc image source pointer.
    def image_source=(value : String | Pointer(Void)) : String | Pointer(Void)
      @style.set_arc_image_src(value)
      value
    end

    # Chaining form of `image_source=`. Applies the same property and returns the same scope instance for further chained calls.
    def image_source(value : String | Pointer(Void)) : self
      self.image_source = value
      self
    end
  end

  # Text-related style properties.
  #
  # ## Properties
  # - `color`, `opacity`, `letter_space`, `line_space`, `decor`, `align`
  # - `outline` for text outline stroke properties
  #
  # ## LVGL mapping
  # - `lv_style_set_text_*`
  #
  # ## Example
  # ```
  # style.text
  #   .color(Lvgl::Color.black)
  #   .opacity(Lvgl::Opacity::Cover)
  #   .letter_space(1)
  #   .line_space(4)
  #   .align(Lvgl::TextAlign::Center)
  #
  # style.text.outline
  #   .width(1)
  #   .color(Lvgl::Palette::Grey.main)
  #   .opacity(Lvgl::Opacity::P20)
  # ```
  #
  # ## Links
  # - [LVGL docs: text style properties (9.4)](https://docs.lvgl.io/9.4/API/misc/lv_style_gen_h.html)
  # - [LVGL 9.4 header](https://github.com/embedconsult/lvgl/blob/v9.4.0/src/misc/lv_style_gen.h)
  class TextScope
    # Create a text-scope wrapper bound to one style instance.
    def initialize(@style : Lvgl::Style)
    end

    # Sets text color.
    def color=(value : Lvgl::Color) : Lvgl::Color
      @style.set_text_color(value)
      value
    end

    # Chaining form of `color=`. Applies the same property and returns the same scope instance for further chained calls.
    def color(value : Lvgl::Color) : self
      self.color = value
      self
    end

    # Sets text opacity (0..255).
    def opacity=(value : Lvgl::Opa | UInt8) : UInt8
      @style.set_text_opa(value)
      value.is_a?(Lvgl::Opa) ? value.to_i.to_u8 : value
    end

    # Chaining form of `opacity=`. Applies the same property and returns the same scope instance for further chained calls.
    def opacity(value : Lvgl::Opa | UInt8) : self
      self.opacity = value
      self
    end

    # Sets letter spacing in pixels.
    def letter_space=(value : Int32) : Int32
      @style.set_text_letter_space(value)
      value
    end

    # Chaining form of `letter_space=`. Applies the same property and returns the same scope instance for further chained calls.
    def letter_space(value : Int32) : self
      self.letter_space = value
      self
    end

    # Sets line spacing in pixels.
    def line_space=(value : Int32) : Int32
      @style.set_text_line_space(value)
      value
    end

    # Chaining form of `line_space=`. Applies the same property and returns the same scope instance for further chained calls.
    def line_space(value : Int32) : self
      self.line_space = value
      self
    end

    # Sets text decoration flags.
    def decor=(value : Lvgl::TextDecor) : Lvgl::TextDecor
      @style.set_text_decor(value)
      value
    end

    # Chaining form of `decor=`. Applies the same property and returns the same scope instance for further chained calls.
    def decor(value : Lvgl::TextDecor) : self
      self.decor = value
      self
    end

    # Sets text alignment.
    def align=(value : Lvgl::TextAlign) : Lvgl::TextAlign
      @style.set_text_align(value)
      value
    end

    # Chaining form of `align=`. Applies the same property and returns the same scope instance for further chained calls.
    def align(value : Lvgl::TextAlign) : self
      self.align = value
      self
    end

    # Returns the text-outline scope bound to the same parent style.
    def outline : TextOutlineScope
      TextOutlineScope.new(@style)
    end
  end

  # Text outline stroke properties.
  #
  # ## Properties
  # - `color`, `width`, `opacity`
  #
  # ## LVGL mapping
  # - `lv_style_set_text_outline_stroke_*`
  #
  # ## Example
  # ```
  # style.text.outline
  #   .width(2)
  #   .color(Lvgl::Color.black)
  #   .opacity(Lvgl::Opacity::P20)
  # ```
  #
  # ## Links
  # - [LVGL docs: text outline style properties (9.4)](https://docs.lvgl.io/9.4/API/misc/lv_style_gen_h.html)
  # - [LVGL 9.4 header](https://github.com/embedconsult/lvgl/blob/v9.4.0/src/misc/lv_style_gen.h)
  class TextOutlineScope
    # Create a text-outline-scope wrapper bound to one style instance.
    def initialize(@style : Lvgl::Style)
    end

    # Sets text outline stroke color.
    def color=(value : Lvgl::Color) : Lvgl::Color
      @style.set_text_outline_stroke_color(value)
      value
    end

    # Chaining form of `color=`. Applies the same property and returns the same scope instance for further chained calls.
    def color(value : Lvgl::Color) : self
      self.color = value
      self
    end

    # Sets text outline stroke width.
    def width=(value : Int32) : Int32
      @style.set_text_outline_stroke_width(value)
      value
    end

    # Chaining form of `width=`. Applies the same property and returns the same scope instance for further chained calls.
    def width(value : Int32) : self
      self.width = value
      self
    end

    # Sets text outline stroke opacity.
    def opacity=(value : Lvgl::Opa | UInt8) : UInt8
      @style.set_text_outline_stroke_opa(value)
      value.is_a?(Lvgl::Opa) ? value.to_i.to_u8 : value
    end

    # Chaining form of `opacity=`. Applies the same property and returns the same scope instance for further chained calls.
    def opacity(value : Lvgl::Opa | UInt8) : self
      self.opacity = value
      self
    end
  end

  # Generic layout/meta style properties.
  #
  # ## Properties
  # - `id`: numeric layout identifier used by LVGL
  # - `base_direction`: text/layout base direction
  #
  # ## LVGL mapping
  # - `lv_style_set_layout`
  # - `lv_style_set_base_dir`
  #
  # ## Example
  # ```
  # style.layout
  #   .id(1)
  #   .base_direction(Lvgl::BaseDirection::Ltr)
  # ```
  #
  # ## Links
  # - [LVGL docs: layout/base-dir style properties (9.4)](https://docs.lvgl.io/9.4/API/misc/lv_style_gen_h.html)
  # - [LVGL 9.4 header](https://github.com/embedconsult/lvgl/blob/v9.4.0/src/misc/lv_style_gen.h)
  class LayoutScope
    # Create a layout-scope wrapper bound to one style instance.
    def initialize(@style : Lvgl::Style)
    end

    # Sets layout identifier.
    def id=(value : UInt16 | Int32) : UInt16 | Int32
      @style.set_layout(value)
      value
    end

    # Chaining form of `id=`. Applies the same property and returns the same scope instance for further chained calls.
    def id(value : UInt16 | Int32) : self
      self.id = value
      self
    end

    # Sets base text direction.
    def base_direction=(value : Lvgl::BaseDirection) : Lvgl::BaseDirection
      @style.set_base_dir(value)
      value
    end

    # Chaining form of `base_direction=`. Applies the same property and returns the same scope instance for further chained calls.
    def base_direction(value : Lvgl::BaseDirection) : self
      self.base_direction = value
      self
    end
  end

  # Flex layout style properties.
  #
  # ## Properties
  # - `flow`, `main_place`, `cross_place`, `track_place`, `grow`
  #
  # ## LVGL mapping
  # - `lv_style_set_flex_*`
  #
  # ## Example
  # ```
  # style.flex
  #   .flow(Lvgl::FlexFlow::RowWrap)
  #   .main_place(Lvgl::FlexAlign::SpaceBetween)
  #   .cross_place(Lvgl::FlexAlign::Center)
  #   .track_place(Lvgl::FlexAlign::Start)
  #   .grow(1)
  # ```
  #
  # ## Links
  # - [LVGL docs: flex style properties (9.4)](https://docs.lvgl.io/9.4/API/misc/lv_style_gen_h.html)
  # - [LVGL flex docs (9.4)](https://docs.lvgl.io/9.4/layouts/flex.html)
  # - [LVGL 9.4 flex header](https://github.com/embedconsult/lvgl/blob/v9.4.0/src/layouts/flex/lv_flex.h)
  class FlexScope
    # Create a flex-scope wrapper bound to one style instance.
    def initialize(@style : Lvgl::Style)
    end

    # Sets flex flow mode.
    def flow=(value : Lvgl::FlexFlow) : Lvgl::FlexFlow
      @style.set_flex_flow(value)
      value
    end

    # Chaining form of `flow=`. Applies the same property and returns the same scope instance for further chained calls.
    def flow(value : Lvgl::FlexFlow) : self
      self.flow = value
      self
    end

    # Sets flex main-axis placement.
    def main_place=(value : Lvgl::FlexAlign) : Lvgl::FlexAlign
      @style.set_flex_main_place(value)
      value
    end

    # Chaining form of `main_place=`. Applies the same property and returns the same scope instance for further chained calls.
    def main_place(value : Lvgl::FlexAlign) : self
      self.main_place = value
      self
    end

    # Sets flex cross-axis placement.
    def cross_place=(value : Lvgl::FlexAlign) : Lvgl::FlexAlign
      @style.set_flex_cross_place(value)
      value
    end

    # Chaining form of `cross_place=`. Applies the same property and returns the same scope instance for further chained calls.
    def cross_place(value : Lvgl::FlexAlign) : self
      self.cross_place = value
      self
    end

    # Sets flex track placement.
    def track_place=(value : Lvgl::FlexAlign) : Lvgl::FlexAlign
      @style.set_flex_track_place(value)
      value
    end

    # Chaining form of `track_place=`. Applies the same property and returns the same scope instance for further chained calls.
    def track_place(value : Lvgl::FlexAlign) : self
      self.track_place = value
      self
    end

    # Sets flex grow factor.
    def grow=(value : UInt8 | Int32) : UInt8 | Int32
      @style.set_flex_grow(value)
      value
    end

    # Chaining form of `grow=`. Applies the same property and returns the same scope instance for further chained calls.
    def grow(value : UInt8 | Int32) : self
      self.grow = value
      self
    end
  end

  # Grid layout style properties.
  #
  # ## Properties
  # - Descriptor arrays: `column_descriptors`, `row_descriptors`
  # - Track align: `column_align`, `row_align`
  # - Cell placement: `cell_column_pos`, `cell_column_span`, `cell_x_align`,
  #   `cell_row_pos`, `cell_row_span`, `cell_y_align`
  #
  # ## Notes
  # `column_descriptors` and `row_descriptors` are raw pointers. Their memory
  # must remain valid for as long as LVGL might resolve layout from this style.
  #
  # ## LVGL mapping
  # - `lv_style_set_grid_*`
  #
  # ## Example
  # ```
  # style.grid
  #   .column_align(Lvgl::GridAlign::SpaceBetween)
  #   .row_align(Lvgl::GridAlign::Center)
  #   .cell_column_pos(0)
  #   .cell_column_span(2)
  #   .cell_x_align(Lvgl::GridAlign::Stretch)
  #   .cell_row_pos(0)
  #   .cell_row_span(1)
  #   .cell_y_align(Lvgl::GridAlign::Center)
  # ```
  #
  # ## Links
  # - [LVGL docs: grid style properties (9.4)](https://docs.lvgl.io/9.4/API/misc/lv_style_gen_h.html)
  # - [LVGL grid docs (9.4)](https://docs.lvgl.io/9.4/layouts/grid.html)
  # - [LVGL 9.4 grid header](https://github.com/embedconsult/lvgl/blob/v9.4.0/src/layouts/grid/lv_grid.h)
  class GridScope
    # Create a grid-scope wrapper bound to one style instance.
    def initialize(@style : Lvgl::Style)
    end

    # Sets pointer to grid column descriptor array.
    def column_descriptors=(value : Pointer(Int32)) : Pointer(Int32)
      @style.set_grid_column_dsc_array(value)
      value
    end

    # Chaining form of `column_descriptors=`. Applies the same property and returns the same scope instance for further chained calls.
    def column_descriptors(value : Pointer(Int32)) : self
      self.column_descriptors = value
      self
    end

    # Sets pointer to grid row descriptor array.
    def row_descriptors=(value : Pointer(Int32)) : Pointer(Int32)
      @style.set_grid_row_dsc_array(value)
      value
    end

    # Chaining form of `row_descriptors=`. Applies the same property and returns the same scope instance for further chained calls.
    def row_descriptors(value : Pointer(Int32)) : self
      self.row_descriptors = value
      self
    end

    # Sets grid column track alignment.
    def column_align=(value : Lvgl::GridAlign) : Lvgl::GridAlign
      @style.set_grid_column_align(value)
      value
    end

    # Chaining form of `column_align=`. Applies the same property and returns the same scope instance for further chained calls.
    def column_align(value : Lvgl::GridAlign) : self
      self.column_align = value
      self
    end

    # Sets grid row track alignment.
    def row_align=(value : Lvgl::GridAlign) : Lvgl::GridAlign
      @style.set_grid_row_align(value)
      value
    end

    # Chaining form of `row_align=`. Applies the same property and returns the same scope instance for further chained calls.
    def row_align(value : Lvgl::GridAlign) : self
      self.row_align = value
      self
    end

    # Sets grid cell column start position.
    def cell_column_pos=(value : Int32) : Int32
      @style.set_grid_cell_column_pos(value)
      value
    end

    # Chaining form of `cell_column_pos=`. Applies the same property and returns the same scope instance for further chained calls.
    def cell_column_pos(value : Int32) : self
      self.cell_column_pos = value
      self
    end

    # Sets grid cell column span.
    def cell_column_span=(value : Int32) : Int32
      @style.set_grid_cell_column_span(value)
      value
    end

    # Chaining form of `cell_column_span=`. Applies the same property and returns the same scope instance for further chained calls.
    def cell_column_span(value : Int32) : self
      self.cell_column_span = value
      self
    end

    # Sets grid cell X alignment.
    def cell_x_align=(value : Lvgl::GridAlign) : Lvgl::GridAlign
      @style.set_grid_cell_x_align(value)
      value
    end

    # Chaining form of `cell_x_align=`. Applies the same property and returns the same scope instance for further chained calls.
    def cell_x_align(value : Lvgl::GridAlign) : self
      self.cell_x_align = value
      self
    end

    # Sets grid cell row start position.
    def cell_row_pos=(value : Int32) : Int32
      @style.set_grid_cell_row_pos(value)
      value
    end

    # Chaining form of `cell_row_pos=`. Applies the same property and returns the same scope instance for further chained calls.
    def cell_row_pos(value : Int32) : self
      self.cell_row_pos = value
      self
    end

    # Sets grid cell row span.
    def cell_row_span=(value : Int32) : Int32
      @style.set_grid_cell_row_span(value)
      value
    end

    # Chaining form of `cell_row_span=`. Applies the same property and returns the same scope instance for further chained calls.
    def cell_row_span(value : Int32) : self
      self.cell_row_span = value
      self
    end

    # Sets grid cell Y alignment.
    def cell_y_align=(value : Lvgl::GridAlign) : Lvgl::GridAlign
      @style.set_grid_cell_y_align(value)
      value
    end

    # Chaining form of `cell_y_align=`. Applies the same property and returns the same scope instance for further chained calls.
    def cell_y_align(value : Lvgl::GridAlign) : self
      self.cell_y_align = value
      self
    end
  end

  # Transition/animation/meta drawing style properties.
  #
  # ## Properties
  # - `descriptor`: transition descriptor pointer
  # - `animation`: animation descriptor pointer
  # - `duration`: animation duration
  # - `blend_mode`: blend mode for draw operations
  #
  # ## Notes
  # Pointer-backed properties (`descriptor`, `animation`) require caller-owned
  # memory that remains valid for LVGL usage.
  #
  # ## LVGL mapping
  # - `lv_style_set_transition`
  # - `lv_style_set_anim`
  # - `lv_style_set_anim_duration`
  # - `lv_style_set_blend_mode`
  #
  # ## Example
  # ```
  # style.transition
  #   .duration(150)
  #   .blend_mode(Lvgl::BlendMode::Normal)
  # ```
  #
  # ## Links
  # - [LVGL docs: transition/blend style properties (9.4)](https://docs.lvgl.io/9.4/API/misc/lv_style_gen_h.html)
  # - [LVGL 9.4 header](https://github.com/embedconsult/lvgl/blob/v9.4.0/src/misc/lv_style_gen.h)
  class TransitionScope
    # Create a transition-scope wrapper bound to one style instance.
    def initialize(@style : Lvgl::Style)
    end

    # Sets transition descriptor pointer.
    def descriptor=(value : Pointer(LibLvgl::LvStyleTransitionDscT)) : Pointer(LibLvgl::LvStyleTransitionDscT)
      @style.set_transition(value)
      value
    end

    # Chaining form of `descriptor=`. Applies the same property and returns the same scope instance for further chained calls.
    def descriptor(value : Pointer(LibLvgl::LvStyleTransitionDscT)) : self
      self.descriptor = value
      self
    end

    # Sets animation descriptor pointer.
    def animation=(value : Pointer(LibLvgl::LvAnimT)) : Pointer(LibLvgl::LvAnimT)
      @style.set_anim(value)
      value
    end

    # Chaining form of `animation=`. Applies the same property and returns the same scope instance for further chained calls.
    def animation(value : Pointer(LibLvgl::LvAnimT)) : self
      self.animation = value
      self
    end

    # Sets animation duration in milliseconds.
    def duration=(value : UInt32 | Int32) : UInt32 | Int32
      @style.set_anim_duration(value)
      value
    end

    # Chaining form of `duration=`. Applies the same property and returns the same scope instance for further chained calls.
    def duration(value : UInt32 | Int32) : self
      self.duration = value
      self
    end

    # Sets draw blend mode.
    def blend_mode=(value : Lvgl::BlendMode) : Lvgl::BlendMode
      @style.set_blend_mode(value)
      value
    end

    # Chaining form of `blend_mode=`. Applies the same property and returns the same scope instance for further chained calls.
    def blend_mode(value : Lvgl::BlendMode) : self
      self.blend_mode = value
      self
    end
  end

  # Color-filter scope.
  #
  # ## Summary
  # Configures LVGL color filtering on this style by installing a callback and
  # filter opacity.
  #
  # ## Notes
  # The callback receives:
  # - the style (`Lvgl::Style`)
  # - the input color (`Lvgl::Color`)
  # - current filter opacity (`UInt8`)
  #
  # It returns the resulting color used by LVGL.
  #
  # ## Example
  # ```
  # style.color.filter(Lvgl::Opacity::P20) do |_style, color, opacity|
  #   color.darken(opacity)
  # end
  # ```
  #
  # ## Links
  # - [LVGL docs: color filter descriptor (9.4)](https://docs.lvgl.io/9.4/API/misc/lv_color_op_h.html)
  # - [LVGL 9.4 color-op header](https://github.com/embedconsult/lvgl/blob/v9.4.0/src/misc/lv_color_op.h)
  class ColorScope
    # Create a color-filter-scope wrapper bound to one style instance.
    def initialize(@style : Lvgl::Style)
    end

    # Install a color filter callback on this style.
    #
    # ## Parameters
    # - `opacity`: Filter opacity passed to LVGL (`lv_opa_t`).
    # - Block:
    #   - input: `style, color, opacity`
    #   - output: filtered `Lvgl::Color`
    #
    # ## Results
    # - Returns: The parent `Lvgl::Style` for convenient chaining.
    #
    # ## Links
    # - [LVGL docs: lv_style_set_color_filter_dsc (9.4)](https://docs.lvgl.io/9.4/API/misc/lv_style_gen_h.html#_CPPv429lv_style_set_color_filter_dscP10lv_style_tPK21lv_color_filter_dsc_t)
    def filter(opacity : Lvgl::Opa | UInt8 = Lvgl::Opa::P20, &block : Lvgl::Style, Lvgl::Color, UInt8 -> Lvgl::Color) : Lvgl::Style
      @style.install_color_filter(opacity, block)
      @style
    end
  end

  @raw : LibLvgl::LvStyleT = LibLvgl::LvStyleT.new
  @color_filter_dsc : LibLvgl::LvColorFilterDscT = LibLvgl::LvColorFilterDscT.new
  @color_filter_token : UInt64?
  @retained_sources : Array(String)?

  # Create and initialize a mutable LVGL style descriptor.
  #
  # ## Links
  # - [LVGL docs: lv_style_init (9.4)](https://docs.lvgl.io/9.4/API/misc/lv_style_h.html#_CPPv413lv_style_initP10lv_style_t)
  def initialize
    Lvgl::Runtime.start
    initialize_raw_style
  end

  # Reset this style to an empty, reusable descriptor.
  #
  # ## Summary
  # Clears all set properties and reinitializes the raw `lv_style_t`.
  #
  # ## Links
  # - [LVGL docs: lv_style_reset (9.4)](https://docs.lvgl.io/9.4/API/misc/lv_style_h.html#_CPPv414lv_style_resetP10lv_style_t)
  def reset : Nil
    Lvgl::Runtime.start
    clear_color_filter_handler
    @retained_sources.try &.clear
    reset_raw_style
    initialize_raw_style
  end

  # Expose pointer for FFI compatibility.
  def to_unsafe : Pointer(LibLvgl::LvStyleT)
    pointerof(@raw)
  end

  # Set corner radius for this style.
  #
  # ## Links
  # - [LVGL docs: lv_style_set_radius (9.4)](https://docs.lvgl.io/9.4/API/misc/lv_style_gen_h.html#_CPPv419lv_style_set_radiusP10lv_style_t7int32_t)
  def radius=(value : Int32 | Lvgl::Radius) : Int32 | Lvgl::Radius
    radius = value.is_a?(Lvgl::Radius) ? value.to_i : value
    LibLvgl.lv_style_set_radius(to_unsafe, radius)
    value
  end

  # Chaining form of `radius=`. Applies the same property and returns the same style instance for further chained calls.
  def radius(value : Int32 | Lvgl::Radius) : self
    self.radius = value
    self
  end

  # Access background style properties.
  def background : BackgroundScope
    BackgroundScope.new(self)
  end

  # Access border style properties.
  def border : BorderScope
    BorderScope.new(self)
  end

  # Access text style properties.
  def text : TextScope
    TextScope.new(self)
  end

  # Access outline style properties.
  def outline : OutlineScope
    OutlineScope.new(self)
  end

  # Access shadow style properties.
  def shadow : ShadowScope
    ShadowScope.new(self)
  end

  # Access line style properties.
  def line : LineScope
    LineScope.new(self)
  end

  # Access arc style properties.
  def arc : ArcScope
    ArcScope.new(self)
  end

  # Access generic layout style properties.
  def layout : LayoutScope
    LayoutScope.new(self)
  end

  # Access flex layout style properties.
  def flex : FlexScope
    FlexScope.new(self)
  end

  # Access grid layout style properties.
  def grid : GridScope
    GridScope.new(self)
  end

  # Access transition/animation style properties.
  def transition : TransitionScope
    TransitionScope.new(self)
  end

  # Access color filter configuration.
  def color : ColorScope
    ColorScope.new(self)
  end

  # Attach this style to an object for a selector.
  #
  # ## Parameters
  # - `object`: target LVGL object wrapper
  # - `selector`: part/state selector (defaults to main/default)
  #
  # ## Example
  # ```
  # style.apply_to(button)
  # style.apply_to(button, selector: Lvgl::Part::Main | Lvgl::State::Pressed)
  # ```
  #
  # ## Links
  # - [LVGL docs: lv_obj_add_style (9.4)](https://docs.lvgl.io/9.4/API/core/lv_obj_style_h.html#_CPPv416lv_obj_add_styleP8lv_obj_tPK10lv_style_t19lv_style_selector_t)
  def apply_to(object : Lvgl::Object, selector : SelectorInput = Lvgl.style_selector) : Nil
    object.add_style(self, selector: selector)
  end

  protected def self.color_filter_callback(
    dsc : Pointer(LibLvgl::LvColorFilterDscT),
    color : LibLvgl::LvColorT,
    opacity : UInt8,
  ) : LibLvgl::LvColorT
    token = dsc.value.user_data.address.to_u64
    handler = @@color_filter_lock.synchronize do
      @@color_filter_handlers[token]?
    end

    return color unless handler

    style_ref, block = handler
    style = style_ref.value
    unless style
      @@color_filter_lock.synchronize do
        @@color_filter_handlers.delete(token)
      end
      return color
    end

    block.call(style, Lvgl::Color.new(color), opacity).to_unsafe
  end

  protected def install_color_filter(opacity : Lvgl::Opa | UInt8, block : ColorFilterBlock) : Nil
    clear_color_filter_handler

    LibLvgl.lv_color_filter_dsc_init(
      pointerof(@color_filter_dsc),
      ->Style.color_filter_callback(Pointer(LibLvgl::LvColorFilterDscT), LibLvgl::LvColorT, UInt8)
    )

    @@color_filter_lock.synchronize do
      token = @@color_filter_next_token
      @@color_filter_next_token += 1_u64
      @color_filter_token = token
      @color_filter_dsc.user_data = Pointer(Void).new(token)
      @@color_filter_handlers[token] = {WeakRef.new(self), block}
    end

    LibLvgl.lv_style_set_color_filter_dsc(to_unsafe, pointerof(@color_filter_dsc))
    set_color_filter_opa(opacity)
  end

  protected def set_bg_color(color : Lvgl::Color) : Nil
    LibLvgl.lv_style_set_bg_color(to_unsafe, color.to_unsafe)
  end

  protected def set_bg_opa(value : Lvgl::Opa | UInt8) : Nil
    opacity = value.is_a?(Lvgl::Opa) ? value.to_i.to_u8 : value
    LibLvgl.lv_style_set_bg_opa(to_unsafe, opacity)
  end

  protected def set_bg_grad_color(color : Lvgl::Color) : Nil
    LibLvgl.lv_style_set_bg_grad_color(to_unsafe, color.to_unsafe)
  end

  protected def set_bg_grad_dir(value : Lvgl::GradDir | Lvgl::GradientDirection) : Nil
    direction = value.is_a?(Lvgl::GradientDirection) ? value.to_grad_dir : value
    LibLvgl.lv_style_set_bg_grad_dir(to_unsafe, direction.to_i)
  end

  protected def set_bg_main_stop(value : Int32) : Nil
    LibLvgl.lv_style_set_bg_main_stop(to_unsafe, value)
  end

  protected def set_bg_grad_stop(value : Int32) : Nil
    LibLvgl.lv_style_set_bg_grad_stop(to_unsafe, value)
  end

  protected def set_bg_main_opa(value : Lvgl::Opa | UInt8) : Nil
    opacity = value.is_a?(Lvgl::Opa) ? value.to_i.to_u8 : value
    LibLvgl.lv_style_set_bg_main_opa(to_unsafe, opacity)
  end

  protected def set_bg_grad_opa(value : Lvgl::Opa | UInt8) : Nil
    opacity = value.is_a?(Lvgl::Opa) ? value.to_i.to_u8 : value
    LibLvgl.lv_style_set_bg_grad_opa(to_unsafe, opacity)
  end

  protected def set_bg_image_src(value : String | Pointer(Void)) : Nil
    pointer = case value
              when String
                retain_source(value)
                value.to_unsafe.as(Void*)
              when Pointer(Void)
                value
              else
                Pointer(Void).null
              end
    LibLvgl.lv_style_set_bg_image_src(to_unsafe, pointer)
  end

  protected def set_bg_image_opa(value : Lvgl::Opa | UInt8) : Nil
    opacity = value.is_a?(Lvgl::Opa) ? value.to_i.to_u8 : value
    LibLvgl.lv_style_set_bg_image_opa(to_unsafe, opacity)
  end

  protected def set_bg_image_recolor(color : Lvgl::Color) : Nil
    LibLvgl.lv_style_set_bg_image_recolor(to_unsafe, color.to_unsafe)
  end

  protected def set_bg_image_recolor_opa(value : Lvgl::Opa | UInt8) : Nil
    opacity = value.is_a?(Lvgl::Opa) ? value.to_i.to_u8 : value
    LibLvgl.lv_style_set_bg_image_recolor_opa(to_unsafe, opacity)
  end

  protected def set_bg_image_tiled(value : Bool) : Nil
    LibLvgl.lv_style_set_bg_image_tiled(to_unsafe, value)
  end

  protected def set_border_color(color : Lvgl::Color) : Nil
    LibLvgl.lv_style_set_border_color(to_unsafe, color.to_unsafe)
  end

  protected def set_border_opa(value : Lvgl::Opa | UInt8) : Nil
    opacity = value.is_a?(Lvgl::Opa) ? value.to_i.to_u8 : value
    LibLvgl.lv_style_set_border_opa(to_unsafe, opacity)
  end

  protected def set_border_width(value : Int32) : Nil
    LibLvgl.lv_style_set_border_width(to_unsafe, value)
  end

  protected def set_border_side(value : Lvgl::BorderSide) : Nil
    LibLvgl.lv_style_set_border_side(to_unsafe, value.to_i)
  end

  protected def set_border_post(value : Bool) : Nil
    LibLvgl.lv_style_set_border_post(to_unsafe, value)
  end

  protected def set_outline_width(value : Int32) : Nil
    LibLvgl.lv_style_set_outline_width(to_unsafe, value)
  end

  protected def set_outline_color(color : Lvgl::Color) : Nil
    LibLvgl.lv_style_set_outline_color(to_unsafe, color.to_unsafe)
  end

  protected def set_outline_opa(value : Lvgl::Opa | UInt8) : Nil
    opacity = value.is_a?(Lvgl::Opa) ? value.to_i.to_u8 : value
    LibLvgl.lv_style_set_outline_opa(to_unsafe, opacity)
  end

  protected def set_outline_pad(value : Int32) : Nil
    LibLvgl.lv_style_set_outline_pad(to_unsafe, value)
  end

  protected def set_shadow_width(value : Int32) : Nil
    LibLvgl.lv_style_set_shadow_width(to_unsafe, value)
  end

  protected def set_shadow_offset_x(value : Int32) : Nil
    LibLvgl.lv_style_set_shadow_offset_x(to_unsafe, value)
  end

  protected def set_shadow_offset_y(value : Int32) : Nil
    LibLvgl.lv_style_set_shadow_offset_y(to_unsafe, value)
  end

  protected def set_shadow_spread(value : Int32) : Nil
    LibLvgl.lv_style_set_shadow_spread(to_unsafe, value)
  end

  protected def set_shadow_color(color : Lvgl::Color) : Nil
    LibLvgl.lv_style_set_shadow_color(to_unsafe, color.to_unsafe)
  end

  protected def set_shadow_opa(value : Lvgl::Opa | UInt8) : Nil
    opacity = value.is_a?(Lvgl::Opa) ? value.to_i.to_u8 : value
    LibLvgl.lv_style_set_shadow_opa(to_unsafe, opacity)
  end

  protected def set_line_width(value : Int32) : Nil
    LibLvgl.lv_style_set_line_width(to_unsafe, value)
  end

  protected def set_line_dash_width(value : Int32) : Nil
    LibLvgl.lv_style_set_line_dash_width(to_unsafe, value)
  end

  protected def set_line_dash_gap(value : Int32) : Nil
    LibLvgl.lv_style_set_line_dash_gap(to_unsafe, value)
  end

  protected def set_line_rounded(value : Bool) : Nil
    LibLvgl.lv_style_set_line_rounded(to_unsafe, value)
  end

  protected def set_line_color(color : Lvgl::Color) : Nil
    LibLvgl.lv_style_set_line_color(to_unsafe, color.to_unsafe)
  end

  protected def set_line_opa(value : Lvgl::Opa | UInt8) : Nil
    opacity = value.is_a?(Lvgl::Opa) ? value.to_i.to_u8 : value
    LibLvgl.lv_style_set_line_opa(to_unsafe, opacity)
  end

  protected def set_arc_width(value : Int32) : Nil
    LibLvgl.lv_style_set_arc_width(to_unsafe, value)
  end

  protected def set_arc_rounded(value : Bool) : Nil
    LibLvgl.lv_style_set_arc_rounded(to_unsafe, value)
  end

  protected def set_arc_color(color : Lvgl::Color) : Nil
    LibLvgl.lv_style_set_arc_color(to_unsafe, color.to_unsafe)
  end

  protected def set_arc_opa(value : Lvgl::Opa | UInt8) : Nil
    opacity = value.is_a?(Lvgl::Opa) ? value.to_i.to_u8 : value
    LibLvgl.lv_style_set_arc_opa(to_unsafe, opacity)
  end

  protected def set_arc_image_src(value : String | Pointer(Void)) : Nil
    pointer = case value
              when String
                retain_source(value)
                value.to_unsafe.as(Void*)
              when Pointer(Void)
                value
              else
                Pointer(Void).null
              end
    LibLvgl.lv_style_set_arc_image_src(to_unsafe, pointer)
  end

  protected def set_text_color(color : Lvgl::Color) : Nil
    LibLvgl.lv_style_set_text_color(to_unsafe, color.to_unsafe)
  end

  protected def set_text_opa(value : Lvgl::Opa | UInt8) : Nil
    opacity = value.is_a?(Lvgl::Opa) ? value.to_i.to_u8 : value
    LibLvgl.lv_style_set_text_opa(to_unsafe, opacity)
  end

  protected def set_text_letter_space(value : Int32) : Nil
    LibLvgl.lv_style_set_text_letter_space(to_unsafe, value)
  end

  protected def set_text_line_space(value : Int32) : Nil
    LibLvgl.lv_style_set_text_line_space(to_unsafe, value)
  end

  protected def set_text_decor(value : Lvgl::TextDecor) : Nil
    LibLvgl.lv_style_set_text_decor(to_unsafe, value.to_i)
  end

  protected def set_text_align(value : Lvgl::TextAlign) : Nil
    LibLvgl.lv_style_set_text_align(to_unsafe, value.to_i)
  end

  protected def set_text_outline_stroke_color(color : Lvgl::Color) : Nil
    LibLvgl.lv_style_set_text_outline_stroke_color(to_unsafe, color.to_unsafe)
  end

  protected def set_text_outline_stroke_width(value : Int32) : Nil
    LibLvgl.lv_style_set_text_outline_stroke_width(to_unsafe, value)
  end

  protected def set_text_outline_stroke_opa(value : Lvgl::Opa | UInt8) : Nil
    opacity = value.is_a?(Lvgl::Opa) ? value.to_i.to_u8 : value
    LibLvgl.lv_style_set_text_outline_stroke_opa(to_unsafe, opacity)
  end

  protected def set_color_filter_opa(value : Lvgl::Opa | UInt8) : Nil
    opacity = value.is_a?(Lvgl::Opa) ? value.to_i.to_u8 : value
    LibLvgl.lv_style_set_color_filter_opa(to_unsafe, opacity)
  end

  protected def set_transition(value : Pointer(LibLvgl::LvStyleTransitionDscT)) : Nil
    LibLvgl.lv_style_set_transition(to_unsafe, value)
  end

  protected def set_anim(value : Pointer(LibLvgl::LvAnimT)) : Nil
    LibLvgl.lv_style_set_anim(to_unsafe, value)
  end

  protected def set_anim_duration(value : UInt32 | Int32) : Nil
    normalized = value.is_a?(Int32) ? value.to_u32 : value
    LibLvgl.lv_style_set_anim_duration(to_unsafe, normalized)
  end

  protected def set_blend_mode(value : Lvgl::BlendMode) : Nil
    LibLvgl.lv_style_set_blend_mode(to_unsafe, value.to_i)
  end

  protected def set_layout(value : UInt16 | Int32) : Nil
    normalized = value.is_a?(Int32) ? value.to_u16 : value
    LibLvgl.lv_style_set_layout(to_unsafe, normalized)
  end

  protected def set_base_dir(value : Lvgl::BaseDirection) : Nil
    LibLvgl.lv_style_set_base_dir(to_unsafe, value.to_i)
  end

  protected def set_flex_flow(value : Lvgl::FlexFlow) : Nil
    LibLvgl.lv_style_set_flex_flow(to_unsafe, value.to_i)
  end

  protected def set_flex_main_place(value : Lvgl::FlexAlign) : Nil
    LibLvgl.lv_style_set_flex_main_place(to_unsafe, value.to_i)
  end

  protected def set_flex_cross_place(value : Lvgl::FlexAlign) : Nil
    LibLvgl.lv_style_set_flex_cross_place(to_unsafe, value.to_i)
  end

  protected def set_flex_track_place(value : Lvgl::FlexAlign) : Nil
    LibLvgl.lv_style_set_flex_track_place(to_unsafe, value.to_i)
  end

  protected def set_flex_grow(value : UInt8 | Int32) : Nil
    normalized = value.is_a?(Int32) ? value.to_u8 : value
    LibLvgl.lv_style_set_flex_grow(to_unsafe, normalized)
  end

  protected def set_grid_column_dsc_array(value : Pointer(Int32)) : Nil
    LibLvgl.lv_style_set_grid_column_dsc_array(to_unsafe, value)
  end

  protected def set_grid_column_align(value : Lvgl::GridAlign) : Nil
    LibLvgl.lv_style_set_grid_column_align(to_unsafe, value.to_i)
  end

  protected def set_grid_row_dsc_array(value : Pointer(Int32)) : Nil
    LibLvgl.lv_style_set_grid_row_dsc_array(to_unsafe, value)
  end

  protected def set_grid_row_align(value : Lvgl::GridAlign) : Nil
    LibLvgl.lv_style_set_grid_row_align(to_unsafe, value.to_i)
  end

  protected def set_grid_cell_column_pos(value : Int32) : Nil
    LibLvgl.lv_style_set_grid_cell_column_pos(to_unsafe, value)
  end

  protected def set_grid_cell_x_align(value : Lvgl::GridAlign) : Nil
    LibLvgl.lv_style_set_grid_cell_x_align(to_unsafe, value.to_i)
  end

  protected def set_grid_cell_column_span(value : Int32) : Nil
    LibLvgl.lv_style_set_grid_cell_column_span(to_unsafe, value)
  end

  protected def set_grid_cell_row_pos(value : Int32) : Nil
    LibLvgl.lv_style_set_grid_cell_row_pos(to_unsafe, value)
  end

  protected def set_grid_cell_y_align(value : Lvgl::GridAlign) : Nil
    LibLvgl.lv_style_set_grid_cell_y_align(to_unsafe, value.to_i)
  end

  protected def set_grid_cell_row_span(value : Int32) : Nil
    LibLvgl.lv_style_set_grid_cell_row_span(to_unsafe, value)
  end

  private def clear_color_filter_handler : Nil
    token = @color_filter_token
    return unless token

    @@color_filter_lock.synchronize do
      @@color_filter_handlers.delete(token)
    end
    @color_filter_token = nil
  end

  private def retain_source(value : String) : Nil
    retained_sources << value
  end

  private def initialize_raw_style : Nil
    LibLvgl.lv_style_init(pointerof(@raw))
  end

  private def reset_raw_style : Nil
    LibLvgl.lv_style_reset(pointerof(@raw))
  end

  private def retained_sources : Array(String)
    @retained_sources ||= [] of String
  end
end
