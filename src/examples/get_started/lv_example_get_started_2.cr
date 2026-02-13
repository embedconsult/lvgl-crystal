# `lv_example_get_started_2` Crystal port.
#
# ## LVGL documentation
# - LVGL get-started example 2 (C):
#   https://docs.lvgl.io/9.4/get-started/quick-overview.html
#
# ## Crystal/Applet deviations from the C example
# - Uses `Lvgl::Applet#setup` for object creation and an instance method event
#   handler (`#btn_event_handler`) rather than a free C callback function.
# - Uses Crystal wrapper types for events and objects (`Lvgl::Event::Message`,
#   `Lvgl::Widgets::Button`, `Lvgl::Widgets::Label`) instead of raw pointers.
# - App lifecycle and the timer loop are managed by `Lvgl.main`.
#
# ## Backend assumptions
# - Runs with the repository's `headless` backend by default
#   (`LVGL_BACKEND=headless`) using LVGL test display/input symbols.
# - `LVGL_BACKEND=wayland` is wired and currently reuses the repository's
#   headless test runtime path for deterministic execution.
# - `LVGL_BACKEND=sdl` remains a placeholder profile.
require "../../lvgl"

class ExampleGetStarted2 < Lvgl::Applet
  @@cnt = 0

  def btn_event_handler(e : Lvgl::Event::Message)
    code = e.code?
    btn = e.target?
    return if code.nil? || btn.nil?

    if code == Lvgl::Event::Code::Clicked
      @@cnt += 1

      # Get the first child of the button, which is the label, and change its text
      label = btn[0]
      label.text = "Button: #{@@cnt}"
    end
  end

  #
  # Create a button with a label and react on click event.
  #
  def setup(screen)
    btn = Lvgl::Widgets::Button.new(screen)     # Add a button to the current screen
    btn.pos = {10, 10}                          # Set its position
    btn.size = {120, 50}                        # Set its size
    btn.on_event(Lvgl::Event::Code::All) do |e| # Assign a callback to the button
      btn_event_handler(e)
    end

    label = Lvgl::Widgets::Label.new(btn) # Add a label to the button
    label.set_text("Button")              # Set the label's text
    label.center
  end
end
