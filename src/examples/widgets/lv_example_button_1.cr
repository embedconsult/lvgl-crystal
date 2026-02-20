require "../../lvgl"

# Basic button with a centered label.
#
# [Original C Source](https://docs.lvgl.io/9.4/examples/widgets/button/lv_example_button_1.html)
#
# ![ExampleWidgetButton1](images/lv_example_button_1.png)
@[Lvgl::ExampleMetadata(section: "Widgets", title: "Simple button with label", image_path: "images/lv_example_button_1.png", source_url: "https://docs.lvgl.io/9.4/examples/widgets/button/lv_example_button_1.html")]
class ExampleWidgetButton1 < Lvgl::Applet
  # Create a basic button and center its label.
  def setup(screen)
    button = Lvgl::Widgets::Button.new(screen)
    button.size = {140, 56}
    button.center

    label = Lvgl::Widgets::Label.new(button)
    label.text = "Click"
    label.center
  end
end
