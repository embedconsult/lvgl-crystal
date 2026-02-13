require "../../lvgl"

# Create styles from scratch for buttons.
class ExampleGetStarted3 < Lvgl::Applet
  private def apply_base_button_style(button : Lvgl::Widgets::Button)
    default_selector = Lvgl.style_selector
    pressed_selector = Lvgl.style_selector(state: Lvgl::State::Pressed)

    button.remove_style_all
    button.set_style_radius(10, default_selector)
    button.set_style_bg_opa(255_u8, default_selector)
    button.set_style_bg_color(Lvgl::Color.hex(0xe0e0e0), default_selector)
    button.set_style_bg_grad_color(Lvgl::Color.hex(0xb0b0b0), default_selector)
    button.set_style_bg_grad_dir(Lvgl::GradDir::Ver, default_selector)
    button.set_style_border_color(Lvgl::Color.hex(0x000000), default_selector)
    button.set_style_border_width(2, default_selector)
    button.set_style_text_color(Lvgl::Color.hex(0x000000), default_selector)

    button.set_style_bg_color(Lvgl::Color.hex(0xc9c9c9), pressed_selector)
    button.set_style_bg_grad_color(Lvgl::Color.hex(0x9a9a9a), pressed_selector)
  end

  def setup(screen)
    btn = Lvgl::Widgets::Button.new(screen)
    btn.pos = {10, 10}
    btn.size = {120, 50}
    apply_base_button_style(btn)

    label = Lvgl::Widgets::Label.new(btn)
    label.text = "Button"
    label.center

    btn2 = Lvgl::Widgets::Button.new(screen)
    btn2.pos = {10, 80}
    btn2.size = {120, 50}
    apply_base_button_style(btn2)
    btn2.set_style_bg_color(Lvgl::Color.hex(0xe53935))
    btn2.set_style_bg_grad_color(Lvgl::Color.hex(0xff8a80))
    btn2.set_style_radius(1000)

    label2 = Lvgl::Widgets::Label.new(btn2)
    label2.text = "Button 2"
    label2.center
  end
end
