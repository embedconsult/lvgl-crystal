require "./types"
require "weak_ref"

class Lvgl::Style
  private alias SelectorInput = Lvgl::StyleSelector | Lvgl::State | Lvgl::Part | Int32 | UInt32
  private alias ColorFilterBlock = Lvgl::Style, Lvgl::Color, UInt8 -> Lvgl::Color

  @@color_filter_lock = Mutex.new
  @@color_filter_handlers = {} of UInt64 => Tuple(WeakRef(Lvgl::Style), ColorFilterBlock)
  @@color_filter_next_token = 1_u64

  class BackgroundScope
    def initialize(@style : Lvgl::Style)
    end

    def opacity=(value : Lvgl::Opa | UInt8) : UInt8
      @style.set_bg_opa(value)
      value.is_a?(Lvgl::Opa) ? value.to_i.to_u8 : value
    end

    def opacity(value : Lvgl::Opa | UInt8) : self
      self.opacity = value
      self
    end

    def color=(value : Lvgl::Color) : Lvgl::Color
      @style.set_bg_color(value)
      value
    end

    def color(value : Lvgl::Color) : self
      self.color = value
      self
    end

    def gradient_color=(value : Lvgl::Color) : Lvgl::Color
      @style.set_bg_grad_color(value)
      value
    end

    def gradient_color(value : Lvgl::Color) : self
      self.gradient_color = value
      self
    end

    def gradient_direction=(value : Lvgl::GradDir | Lvgl::GradientDirection) : Lvgl::GradDir | Lvgl::GradientDirection
      @style.set_bg_grad_dir(value)
      value
    end

    def gradient_direction(value : Lvgl::GradDir | Lvgl::GradientDirection) : self
      self.gradient_direction = value
      self
    end
  end

  class BorderScope
    def initialize(@style : Lvgl::Style)
    end

    def color=(value : Lvgl::Color) : Lvgl::Color
      @style.set_border_color(value)
      value
    end

    def color(value : Lvgl::Color) : self
      self.color = value
      self
    end

    def opacity=(value : Lvgl::Opa | UInt8) : UInt8
      @style.set_border_opa(value)
      value.is_a?(Lvgl::Opa) ? value.to_i.to_u8 : value
    end

    def opacity(value : Lvgl::Opa | UInt8) : self
      self.opacity = value
      self
    end

    def width=(value : Int32) : Int32
      @style.set_border_width(value)
      value
    end

    def width(value : Int32) : self
      self.width = value
      self
    end
  end

  class TextScope
    def initialize(@style : Lvgl::Style)
    end

    def color=(value : Lvgl::Color) : Lvgl::Color
      @style.set_text_color(value)
      value
    end

    def color(value : Lvgl::Color) : self
      self.color = value
      self
    end
  end

  class ColorScope
    def initialize(@style : Lvgl::Style)
    end

    def filter(opacity : Lvgl::Opa | UInt8 = Lvgl::Opa::P20, &block : Lvgl::Style, Lvgl::Color, UInt8 -> Lvgl::Color) : Lvgl::Style
      @style.install_color_filter(opacity, block)
      @style
    end
  end

  @raw : LibLvgl::LvStyleT = LibLvgl::LvStyleT.new
  @color_filter_dsc : LibLvgl::LvColorFilterDscT = LibLvgl::LvColorFilterDscT.new
  @color_filter_token : UInt64?

  def initialize
    Lvgl::Runtime.start
    initialize_raw_style
  end

  def reset : Nil
    Lvgl::Runtime.start
    clear_color_filter_handler
    reset_raw_style
    initialize_raw_style
  end

  def to_unsafe : Pointer(LibLvgl::LvStyleT)
    pointerof(@raw)
  end

  def radius=(value : Int32 | Lvgl::Radius) : Int32 | Lvgl::Radius
    radius = value.is_a?(Lvgl::Radius) ? value.to_i : value
    LibLvgl.lv_style_set_radius(to_unsafe, radius)
    value
  end

  def radius(value : Int32 | Lvgl::Radius) : self
    self.radius = value
    self
  end

  def background : BackgroundScope
    BackgroundScope.new(self)
  end

  def border : BorderScope
    BorderScope.new(self)
  end

  def text : TextScope
    TextScope.new(self)
  end

  def color : ColorScope
    ColorScope.new(self)
  end

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

  protected def set_text_color(color : Lvgl::Color) : Nil
    LibLvgl.lv_style_set_text_color(to_unsafe, color.to_unsafe)
  end

  protected def set_color_filter_opa(value : Lvgl::Opa | UInt8) : Nil
    opacity = value.is_a?(Lvgl::Opa) ? value.to_i.to_u8 : value
    LibLvgl.lv_style_set_color_filter_opa(to_unsafe, opacity)
  end

  private def clear_color_filter_handler : Nil
    token = @color_filter_token
    return unless token

    @@color_filter_lock.synchronize do
      @@color_filter_handlers.delete(token)
    end
    @color_filter_token = nil
  end

  private def initialize_raw_style : Nil
    LibLvgl.lv_style_init(pointerof(@raw))
  end

  private def reset_raw_style : Nil
    LibLvgl.lv_style_reset(pointerof(@raw))
  end
end
