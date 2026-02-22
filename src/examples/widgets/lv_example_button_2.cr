require "../../lvgl"

# Toggle button visual state and update text from click events.
#
# [Original C Source](https://docs.lvgl.io/9.4/examples.html#styling-buttons)
#
# ![ExampleWidgetButton2](images/lv_example_button_2.png)
@[Lvgl::ExampleMetadata(section: "Widgets", title: "Button press state toggled by click", image_path: "images/lv_example_button_2.png", source_url: "https://docs.lvgl.io/9.4/examples.html#styling-buttons")]
class ExampleWidgetButton2 < Lvgl::Applet
  @pressed = false

  private def update_button(button : Lvgl::Widgets::Button)
    if @pressed
      button.add_state(Lvgl::State::Pressed)
      button.set_style_bg_color(Lvgl::Palette::Red.main, Lvgl::State::Pressed | Lvgl::Part::Main)
      button[0].text = "Pressed"
    else
      button.remove_state(Lvgl::State::Pressed)
      button[0].text = "Released"
    end
  end

  # Create a button and toggle its pressed state on each click.
  def setup(screen)
    button = Lvgl::Widgets::Button.new(screen)
    button.size = {160, 56}
    button.center

    label = Lvgl::Widgets::Label.new(button)
    label.text = "Released"
    label.center

    button.on_event(Lvgl::Event::Code::Clicked) do |_event|
      @pressed = !@pressed
      update_button(button)
    end
  end
end
