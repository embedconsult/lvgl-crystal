require "../../lvgl"

# A button with a label and react on click event
#
# [Original C Source](https://docs.lvgl.io/9.4/examples.html#a-button-with-a-label-and-react-on-click-event)
#
# ![ExampleGetStarted2](images/lv_example_get_started_2.png)
@[Lvgl::ExampleMetadata(section: "Get Started", title: "A button with a label and react on click event", image_path: "images/lv_example_get_started_2.png", source_url: "https://docs.lvgl.io/9.4/examples.html#a-button-with-a-label-and-react-on-click-event")]
class ExampleGetStarted2 < Lvgl::Applet
  @@cnt = 0

  # Button click event handler
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

  # Create a button with a label and react on click event.
  def setup(screen)
    btn = Lvgl::Widgets::Button.new(screen)     # Add a button to the current screen
    btn.pos = {10, 10}                          # Set its position
    btn.size = {120, 50}                        # Set its size
    btn.on_event(Lvgl::Event::Code::All) do |e| # Assign a callback to the button
      btn_event_handler(e)
    end

    label = Lvgl::Widgets::Label.new(btn) # Add a label to the button
    label.text = "Button"                 # Set the label's text
    label.center
  end
end
