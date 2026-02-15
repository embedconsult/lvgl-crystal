require "../spec_helper"

describe Lvgl::Style do
  it "supports expressive style composition and native style attachment" do
    Lvgl::SpecSupport::Harness.with_runtime do
      base = Lvgl::Style.new
      base.radius = 10
      base.radius=(10)
      base.background.opacity = Lvgl::Opacity::Cover
      base.background.opacity=(Lvgl::Opacity::Cover)
      base.background.color = Lvgl::Palette::Grey.lighten(3)
      base.background.color=(Lvgl::Palette::Grey.lighten(3))
      base.background.gradient_color = Lvgl::Palette::Grey.main
      base.background.gradient_color=(Lvgl::Palette::Grey.main)
      base.background.gradient_direction = Lvgl::GradientDirection::Vertical
      base.background.gradient_direction=(Lvgl::GradientDirection::Vertical)
      base.border.color = Lvgl::Color.black
      base.border.color=(Lvgl::Color.black)
      base.border.opacity = Lvgl::Opacity::P20
      base.border.opacity=(Lvgl::Opacity::P20)
      base.border.width = 2
      base.border.width=(2)
      base.text.color = Lvgl::Color.black
      base.text.color=(Lvgl::Color.black)
      base.background
        .opacity(Lvgl::Opacity::Cover)
        .color(Lvgl::Palette::Grey.lighten(3))
        .gradient_color(Lvgl::Palette::Grey.main)
        .gradient_direction(Lvgl::GradientDirection::Vertical)
      base.border
        .color(Lvgl::Color.black)
        .opacity(Lvgl::Opacity::P20)
        .width(2)
      base.text.color(Lvgl::Color.black)
      base.radius(Lvgl::Radius::Circle)

      pressed = Lvgl::Style.new
      pressed.color.filter do |_style, color, opacity|
        color.darken(opacity)
      end

      button = Lvgl::Button.new(nil)
      button.style.remove_all
      button.position = {10, 10}
      button.position=({10, 10})
      button.size = {120, 50}
      base.apply_to(button, Lvgl.style_selector)
      button.style.add(base)
      button.style.add(pressed, selector: Lvgl::State::Pressed)
      button.style.add(pressed, selector: Lvgl::Part::Main | Lvgl::State::Pressed)
      button.add_style(base, selector: Lvgl::State::Pressed)
      button.add_state(Lvgl::State::Pressed)
      button.remove_state(Lvgl::State::Pressed)
      button.style.radius(Lvgl::Radius::Circle, selector: 0)
      button.set_style_bg_grad_dir(Lvgl::GradientDirection::Vertical)
      button.get_style_prop(Lvgl::Part::Main, Lvgl::StyleProp::BgColor)

      button.raw.null?.should be_false
    end
  end

  it "applies pressed color filters when selector state is active" do
    Lvgl::SpecSupport::Harness.with_runtime do
      base = Lvgl::Style.new
      base.background.color = Lvgl::Palette::Red.main
      pressed = Lvgl::Style.new
      pressed.color.filter(Lvgl::Opacity::P20) do |_style, color, opacity|
        color.darken(opacity)
      end

      button = Lvgl::Button.new(nil)
      button.style.remove_all
      button.style.add(base)
      button.style.add(pressed, selector: Lvgl::State::Pressed)

      base_color = button.get_style_prop(Lvgl::Part::Main, Lvgl::StyleProp::BgColor)
      default_filtered = button.apply_style_color_filter(Lvgl::Part::Main, base_color)

      button.add_state(Lvgl::State::Pressed)
      pressed_color = button.get_style_prop(Lvgl::Part::Main, Lvgl::StyleProp::BgColor)
      pressed_filtered = button.apply_style_color_filter(Lvgl::Part::Main, pressed_color)
      button.remove_state(Lvgl::State::Pressed)

      default_raw = default_filtered.color
      pressed_raw = pressed_filtered.color

      {default_raw.red, default_raw.green, default_raw.blue}.should_not eq(
        {pressed_raw.red, pressed_raw.green, pressed_raw.blue}
      )
    end
  end

  it "exposes color convenience helpers" do
    Lvgl::Color.black.should be_a(Lvgl::Color)
    Lvgl::Color.black.darken.should be_a(Lvgl::Color)
    Lvgl::GradientDirection::Vertical.to_grad_dir.should eq(Lvgl::GradDir::Ver)
  end

  it "can reset style descriptors for reuse" do
    style = Lvgl::Style.new
    style.reset
  end
end
