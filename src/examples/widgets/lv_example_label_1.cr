require "../../lvgl"

# Label alignment and text color styling basics.
#
# [Original C Source](https://docs.lvgl.io/9.4/examples.html#line-wrap-recoloring-and-scrolling)
#
# ![ExampleWidgetLabel1](images/lv_example_label_1.png)
@[Lvgl::ExampleMetadata(section: "Widgets", summary: "Highlights label alignment and style settings to compare layout positions and text presentation options.", title: "Label alignment with simple styles", image_path: "images/lv_example_label_1.png", source_url: "https://docs.lvgl.io/9.4/examples.html#line-wrap-recoloring-and-scrolling")]
class ExampleWidgetLabel1 < Lvgl::Applet
  # Build three labels to demonstrate positioning and text color.
  def setup(screen)
    screen.set_style_bg_color(Lvgl::Color.hex(0x1f2933), Lvgl::Part::Main)

    title = Lvgl::Widgets::Label.new(screen)
    title.text = "LVGL Label"
    title.set_style_text_color(Lvgl::Color.hex(0xfafafa), Lvgl::Part::Main)
    title.align(Lvgl::Align::Center, offset: {0, -24})

    subtitle = Lvgl::Widgets::Label.new(screen)
    subtitle.text = "Aligned center"
    subtitle.set_style_text_color(Lvgl::Color.hex(0xa7c5eb), Lvgl::Part::Main)
    subtitle.align(Lvgl::Align::Center, offset: {0, 0})

    footer = Lvgl::Widgets::Label.new(screen)
    footer.text = "Text color via style API"
    footer.set_style_text_color(Lvgl::Color.hex(0x89d185), Lvgl::Part::Main)
    footer.align(Lvgl::Align::Center, offset: {0, 24})
  end
end
