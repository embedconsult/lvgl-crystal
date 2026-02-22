require "../../lvgl"

# Show how label alignment can be used in common positions.
#
# ![ExampleWidgetsLabelAlignment](images/example_widgets_label_alignment.png)
@[Lvgl::ExampleMetadata(section: "Widgets", title: "Label alignment positions", image_path: "images/example_widgets_label_alignment.png")]
class ExampleWidgetsLabelAlignment < Lvgl::Applet
  def setup(screen)
    header = Lvgl::Widgets::Label.new(screen)
    header.text = "Label alignment"
    header.pos = {130, 16}

    top_left = Lvgl::Widgets::Label.new(screen)
    top_left.text = "Top Left"
    top_left.pos = {12, 50}

    centered = Lvgl::Widgets::Label.new(screen)
    centered.text = "Centered"
    centered.align(Lvgl::Align::Center, offset: {0, 0})

    bottom_right = Lvgl::Widgets::Label.new(screen)
    bottom_right.text = "Bottom Right"
    bottom_right.pos = {210, 210}
  end
end
