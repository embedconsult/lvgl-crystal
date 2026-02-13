# `lv_example_get_started_1` Crystal port.
#
# ## LVGL documentation
# - LVGL get-started example 1 (C):
#   https://docs.lvgl.io/9.4/get-started/quick-overview.html
#
# ## Crystal/Applet deviations from the C example
# - Uses `Lvgl::Applet#setup` instead of a C `main` function with explicit
#   display/input driver initialization.
# - Uses Crystal wrapper objects (`Lvgl::Object`, `Lvgl::Widgets::Label`) and
#   wrapper style helpers (`set_style_bg_color`, `set_style_text_color`).
# - Lifecycle (`lv_init`, timer loop, teardown) is handled by `Lvgl.main`.
#
# ## Backend assumptions
# - Runs with the repository's `headless` backend by default
#   (`LVGL_BACKEND=headless`) using LVGL test display/input symbols.
# - `LVGL_BACKEND=wayland` uses LVGL's native Wayland backend when `liblvgl.so` is built with `-DLV_USE_WAYLAND=1`.
# - `LVGL_BACKEND=sdl` remains a placeholder profile.
require "../../lvgl"

# Basic example to create a "Hello world" label.
class ExampleGetStarted1 < Lvgl::Applet
  def setup(screen)
    # Change the active screen's background color.
    screen.set_style_bg_color(Lvgl::Color.hex(0x003a57), Lvgl::Part::Main)

    # Create a white label, set its text and align it to the center.
    label = Lvgl::Widgets::Label.new(screen)
    label.set_text("Hello world")
    label.set_style_text_color(Lvgl::Color.hex(0xffffff), selector: Lvgl::Part::Main)
    label.align(Lvgl::Align::Center, offset: {0, 0})
  end
end
