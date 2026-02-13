require "../../lvgl"

# Create styles from scratch for buttons.
class ExampleGetStarted3 < Lvgl::Applet
  private def apply_base_button_style(button : Lvgl::Widgets::Button)
    pressed_selector = Lvgl.style_selector(state: Lvgl::State::Pressed)

    button.remove_style_all
    button.set_style_radius(10)
    button.set_style_bg_opa(255_u8)
    button.set_style_bg_color(Lvgl::Color.hex(0xeeeeee))
    button.set_style_bg_grad_color(Lvgl::Color.hex(0x9e9e9e))
    button.set_style_bg_grad_dir(Lvgl::GradDir::Ver)
    button.set_style_border_color(Lvgl::Color.hex(0x000000))
    button.set_style_border_opa(51_u8)
    button.set_style_border_width(2)
    button.set_style_text_color(Lvgl::Color.hex(0x000000))

    button.set_style_bg_color(Lvgl::Color.hex(0xbebebe), pressed_selector)
    button.set_style_bg_grad_color(Lvgl::Color.hex(0x7e7e7e), pressed_selector)
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
    btn2.set_style_bg_color(Lvgl::Color.hex(0xf44336))
    btn2.set_style_bg_grad_color(Lvgl::Color.hex(0xef9a9a))
    btn2.set_style_radius(1000)

    label2 = Lvgl::Widgets::Label.new(btn2)
    label2.text = "Button 2"
    label2.center
  end
end
