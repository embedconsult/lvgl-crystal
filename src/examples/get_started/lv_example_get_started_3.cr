require "../../lvgl"

# Create styles from scratch for buttons.
#
# A Crystal-friendly adaptation of LVGL's get-started style example.
class ExampleGetStarted3 < Lvgl::Applet
  @normal_color = Lvgl::Color.hex(0xd6d6d6)
  @pressed_color = Lvgl::Color.hex(0xb5b5b5)

  private def apply_base_style(button : Lvgl::Widgets::Button)
    button.set_style_bg_color(@normal_color)
    button.set_style_text_color(Lvgl::Color.hex(0x000000))
  end

  private def wire_pressed_feedback(button : Lvgl::Widgets::Button)
    button.on_event(Lvgl::Event::Code::Pressed) { |_| button.set_style_bg_color(@pressed_color) }
    button.on_event(Lvgl::Event::Code::Released) { |_| button.set_style_bg_color(@normal_color) }
  end

  def setup(screen)
    first = Lvgl::Widgets::Button.new(screen)
    first.pos = {10, 10}
    first.size = {120, 50}
    apply_base_style(first)
    wire_pressed_feedback(first)

    first_label = Lvgl::Widgets::Label.new(first)
    first_label.text = "Button"
    first_label.center

    second = Lvgl::Widgets::Button.new(screen)
    second.pos = {10, 80}
    second.size = {120, 50}
    second.set_style_bg_color(Lvgl::Color.hex(0xff4d4f))
    second.set_style_text_color(Lvgl::Color.hex(0x000000))
    wire_pressed_feedback(second)

    second_label = Lvgl::Widgets::Label.new(second)
    second_label.text = "Button 2"
    second_label.center
  end
end
