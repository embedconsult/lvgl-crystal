require "../../lvgl"

# Create a slider and write its value on a label.
#
# A Crystal-friendly adaptation of LVGL's get-started slider example.
class ExampleGetStarted4 < Lvgl::Applet
  @value_label : Lvgl::Widgets::Label?

  private def refresh_label(slider : Lvgl::Widgets::Slider)
    label = @value_label
    return unless label

    label.text = slider.value.to_s
  end

  def setup(screen)
    slider = Lvgl::Widgets::Slider.new(screen)
    slider.size = {200, 20}
    slider.center

    label = Lvgl::Widgets::Label.new(screen)
    label.text = "0"
    label.align(Lvgl::Align::Center, offset: {0, -30})
    @value_label = label

    slider.on_event(Lvgl::Event::Code::ValueChanged) do |_|
      refresh_label(slider)
    end
  end
end
