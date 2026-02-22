require "../../lvgl"

# Two sliders where one mirrors the other's value.
#
# [Original C Source](https://docs.lvgl.io/9.4/examples.html#slider-with-custom-style)
#
# ![ExampleWidgetSlider2](images/lv_example_slider_2.png)
@[Lvgl::ExampleMetadata(section: "Widgets", title: "Slider value mirrored across two sliders", image_path: "images/lv_example_slider_2.png", source_url: "https://docs.lvgl.io/9.4/examples.html#slider-with-custom-style")]
class ExampleWidgetSlider2 < Lvgl::Applet
  # Create two sliders and keep the second slider synchronized with the first.
  def setup(screen)
    primary_slider = Lvgl::Widgets::Slider.new(screen)
    primary_slider.size = {220, 18}
    primary_slider.align(Lvgl::Align::Center, offset: {0, -24})

    mirrored_slider = Lvgl::Widgets::Slider.new(screen)
    mirrored_slider.size = {220, 18}
    mirrored_slider.align(Lvgl::Align::Center, offset: {0, 16})
    mirrored_slider.value = primary_slider.value

    value_label = Lvgl::Widgets::Label.new(screen)
    value_label.align(Lvgl::Align::Center, offset: {0, -50})
    value_label.text = "Value: #{primary_slider.value}"

    primary_slider.on_event(Lvgl::Event::Code::ValueChanged) do |_event|
      current = primary_slider.value
      mirrored_slider.value = current
      value_label.text = "Value: #{current}"
    end
  end
end
