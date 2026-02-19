require "../../lvgl"

# Toggle a button label between ON and OFF when clicked.
#
# ![ExampleWidgetsButtonToggle](images/example_widgets_button_toggle.png)
@[Lvgl::ExampleMetadata(section: "Widgets", title: "Button toggle with click event", image_path: "images/example_widgets_button_toggle.png")]
class ExampleWidgetsButtonToggle < Lvgl::Applet
  @status_label : Lvgl::Widgets::Label?
  @enabled = false

  private def sync_label
    label = @status_label
    return unless label

    label.text = @enabled ? "Status: ON" : "Status: OFF"
  end

  def setup(screen)
    title = Lvgl::Widgets::Label.new(screen)
    title.text = "Toggle button"
    title.pos = {140, 24}

    button = Lvgl::Widgets::Button.new(screen)
    button.size = {160, 56}
    button.align(Lvgl::Align::Center, offset: {0, -10})

    button_text = Lvgl::Widgets::Label.new(button)
    button_text.text = "Tap me"
    button_text.center

    status = Lvgl::Widgets::Label.new(screen)
    status.align(Lvgl::Align::Center, offset: {0, 46})
    @status_label = status
    sync_label

    button.on_event(Lvgl::Event::Code::Clicked) do |_event|
      @enabled = !@enabled
      sync_label
    end
  end
end
