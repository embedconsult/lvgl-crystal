require "../../lvgl"

# Two buttons that update a shared label.
#
# [Original C Source](https://docs.lvgl.io/9.4/examples.html#gummy-button)
#
# ![ExampleWidgetButton3](images/lv_example_button_3.png)
@[Lvgl::ExampleMetadata(section: "Widgets", title: "Button pair with shared status label", image_path: "images/lv_example_button_3.png", source_url: "https://docs.lvgl.io/9.4/examples.html#gummy-button")]
class ExampleWidgetButton3 < Lvgl::Applet
  # Build increment/decrement buttons that update a status label.
  def setup(screen)
    value = 0

    status = Lvgl::Widgets::Label.new(screen)
    status.text = "Value: #{value}"
    status.align(Lvgl::Align::Center, offset: {0, -46})

    decrement = Lvgl::Widgets::Button.new(screen)
    decrement.size = {80, 44}
    decrement.align(Lvgl::Align::Center, offset: {-56, 4})

    decrement_label = Lvgl::Widgets::Label.new(decrement)
    decrement_label.text = "-"
    decrement_label.center

    increment = Lvgl::Widgets::Button.new(screen)
    increment.size = {80, 44}
    increment.align(Lvgl::Align::Center, offset: {56, 4})

    increment_label = Lvgl::Widgets::Label.new(increment)
    increment_label.text = "+"
    increment_label.center

    decrement.on_event(Lvgl::Event::Code::Clicked) do |_event|
      value -= 1
      status.text = "Value: #{value}"
    end

    increment.on_event(Lvgl::Event::Code::Clicked) do |_event|
      value += 1
      status.text = "Value: #{value}"
    end
  end
end
