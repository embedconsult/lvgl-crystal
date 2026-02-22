require "../../lvgl"

# Update a label as a slider value changes.
#
# ![ExampleWidgetsSliderValue](images/example_widgets_slider_value.png)
@[Lvgl::ExampleMetadata(section: "Widgets", title: "Slider value indicator", image_path: "images/example_widgets_slider_value.png")]
class ExampleWidgetsSliderValue < Lvgl::Applet
  @value_label : Lvgl::Widgets::Label?

  private def update_value(slider : Lvgl::Widgets::Slider)
    label = @value_label
    return unless label

    label.text = "Value: #{slider.value}"
  end

  def setup(screen)
    title = Lvgl::Widgets::Label.new(screen)
    title.text = "Slider"
    title.pos = {155, 20}

    slider = Lvgl::Widgets::Slider.new(screen)
    slider.size = {220, 16}
    slider.align(Lvgl::Align::Center, offset: {0, 4})

    value = Lvgl::Widgets::Label.new(screen)
    value.align(Lvgl::Align::Center, offset: {0, -30})
    @value_label = value
    update_value(slider)

    slider.on_event(Lvgl::Event::Code::ValueChanged) do |_event|
      update_value(slider)
    end
  end
end
