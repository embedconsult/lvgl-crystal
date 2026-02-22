require "../../lvgl"

# Slider event handling with a value readout label.
#
# [Original C Source](https://docs.lvgl.io/9.4/examples.html#simple-slider)
#
# ![ExampleWidgetSlider1](images/lv_example_slider_1.png)
@[Lvgl::ExampleMetadata(section: "Widgets", title: "Slider with live value label", image_path: "images/lv_example_slider_1.png", source_url: "https://docs.lvgl.io/9.4/examples.html#simple-slider")]
class ExampleWidgetSlider1 < Lvgl::Applet
  @value_label : Lvgl::Widgets::Label?

  private def update_value(slider : Lvgl::Widgets::Slider)
    label = @value_label
    return unless label

    label.text = "Value: #{slider.value}"
  end

  # Create one slider and mirror the current value into a label.
  def setup(screen)
    slider = Lvgl::Widgets::Slider.new(screen)
    slider.size = {220, 18}
    slider.center

    value_label = Lvgl::Widgets::Label.new(screen)
    value_label.align(Lvgl::Align::Center, offset: {0, -32})
    @value_label = value_label

    slider.on_event(Lvgl::Event::Code::ValueChanged) do |_event|
      update_value(slider)
    end

    update_value(slider)
  end
end
