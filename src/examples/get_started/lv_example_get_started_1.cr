require "../../lvgl-crystal"

#
# Basic example to create a "Hello world" label
#
def lv_example_get_started_1(screen)
    # Change the active screen's background color
    screen.set_style_bg_color(Lvgl::Color.hex(0x003a57), Lvgl::LV_PART_MAIN)

    # Create a white label, set its text and align it to the center
    label = Lvgl::Widgets::Label.new(screen)
    label.set_text("Hello world")
    label.set_style_text_color(Lvgl::Color.hex(0xffffff), Lvgl::LV_PART_MAIN);
    label.align(label, Lvgl::LV_ALIGN_CENTER, 0, 0);
end

Lvgl::Crystal::setup do |screen|
  lv_example_get_started_1(screen)
end

Lvgl::Crystal::loop do |screen|
  Lvgl::Crystal::EXIT_ON_CLOSE
end

Lvgl::Crystal::cleanup do |screen|
end
