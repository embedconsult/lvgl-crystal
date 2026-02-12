#
# Based on LVGL examples/get_started/lv_example_get_started_1.c
#
require "../../lvgl-crystal"

#
# Basic example to create a "Hello world" label
#
class ExampleGetStarted1 < Lvgl::Crystal::Applet
  def setup(screen)
    # Change the active screen's background color
    screen.set_style_bg_color(Lvgl::Color.hex(0x003a57), Lvgl::LV_PART_MAIN)

    # Create a white label, set its text and align it to the center
    label = Lvgl::Widgets::Label.new(screen)
    label.set_text("Hello world")
    label.set_style_text_color(Lvgl::Color.hex(0xffffff), selector: Lvgl::Part::Main)
    label.align(Lvgl::Align::Center, offset: {0, 0})
  end
end
