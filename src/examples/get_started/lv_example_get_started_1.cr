require "../../lvgl"

# Basic example to create a "Hello world" label.
#
# [Original C Source](https://docs.lvgl.io/9.4/examples.html#a-very-simple-hello-world-label)
#
# ![ExampleGetStarted1](images/lv_example_get_started_1.png)
@[Lvgl::ExampleMetadata(section: "Get Started", summary: "Shows the smallest end-to-end LVGL applet: a single centered label with explicit screen and text styling.", title: "A very simple _hello world_ label", image_path: "images/lv_example_get_started_1.png", source_url: "https://docs.lvgl.io/9.4/examples.html#a-very-simple-hello-world-label")]
class ExampleGetStarted1 < Lvgl::Applet
  # Setup the window
  def setup(screen)
    # Change the active screen's background color.
    screen.set_style_bg_color(Lvgl::Color.hex(0x003a57), Lvgl::Part::Main)

    # Create a white label, set its text and align it to the center.
    label = Lvgl::Widgets::Label.new(screen)
    label.text = "Hello world"
    label.set_style_text_color(Lvgl::Color.hex(0xffffff), Lvgl::Part::Main)
    label.align(Lvgl::Align::Center, offset: {0, 0})
  end
end
