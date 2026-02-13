require "../../lvgl"

# Create styles from scratch for buttons.
class ExampleGetStarted3 < Lvgl::Applet
  private def apply_base_button_style(button : Lvgl::Widgets::Button)
    grey_bg = Lvgl::Palette::Grey.lighten(3)
    grey_bg_grad = Lvgl::Palette::Grey.main
    pressed_selector = Lvgl.style_selector(state: Lvgl::State::Pressed)

    button.remove_style_all
    button.set_style_radius(10)
    button.set_style_bg_opa(Lvgl::Opa::Cover.to_i.to_u8)
    button.set_style_bg_color(grey_bg)
    button.set_style_bg_grad_color(grey_bg_grad)
    button.set_style_bg_grad_dir(Lvgl::GradDir::Ver)
    button.set_style_border_color(Lvgl::Color.hex(0x000000))
    button.set_style_border_opa(Lvgl::Opa::P20.to_i.to_u8)
    button.set_style_border_width(2)
    button.set_style_text_color(Lvgl::Color.hex(0x000000))

    # Simulate LVGL's example darken filter for the pressed state.
    button.set_style_bg_color(grey_bg.darken(Lvgl::Opa::P20), pressed_selector)
    button.set_style_bg_grad_color(grey_bg_grad.darken(Lvgl::Opa::P20), pressed_selector)
  end

  def setup(screen)
    btn = Lvgl::Widgets::Button.new(screen)
    btn.remove_style_all
    btn.pos = {10, 10}
    btn.size = {120, 50}
    apply_base_button_style(btn)

    label = Lvgl::Widgets::Label.new(btn)
    label.text = "Button"
    label.center

    btn2 = Lvgl::Widgets::Button.new(screen)
    btn2.remove_style_all
    btn2.pos = {10, 80}
    btn2.size = {120, 50}
    apply_base_button_style(btn2)
    btn2.set_style_bg_color(Lvgl::Palette::Red.main)
    btn2.set_style_bg_grad_color(Lvgl::Palette::Red.lighten(3))
    btn2.set_style_radius(1000)

    label2 = Lvgl::Widgets::Label.new(btn2)
    label2.text = "Button 2"
    label2.center
  end
end
