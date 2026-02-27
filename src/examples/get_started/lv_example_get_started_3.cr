require "../../lvgl"

# Create styles from scratch for buttons.
#
# [Original C Source](https://docs.lvgl.io/9.4/examples.html#create-styles-from-scratch-for-buttons)
#
# ![ExampleGetStarted3](images/lv_example_get_started_3.png)
@[Lvgl::ExampleMetadata(section: "Get Started", summary: "Builds button styling from scratch to demonstrate stateful style configuration and palette usage.", title: "Create styles from scratch for buttons", image_path: "images/lv_example_get_started_3.png", source_url: "https://docs.lvgl.io/9.4/examples.html#create-styles-from-scratch-for-buttons")]
class ExampleGetStarted3 < Lvgl::Applet
  @style_btn : Lvgl::Style
  @style_button_pressed : Lvgl::Style
  @style_button_red : Lvgl::Style

  # Create a simple button style.
  #
  # This is done in `initialize` to be available for use in `setup`.
  def initialize
    @style_btn = Lvgl::Style.new
    @style_btn.radius = 10
    @style_btn.background.opacity = Lvgl::Opacity::Cover
    @style_btn.background.color = Lvgl::Palette::Grey.lighten(3)
    @style_btn.background.gradient_color = Lvgl::Palette::Grey.main
    @style_btn.background.gradient_direction = Lvgl::GradientDirection::Vertical

    @style_btn.border.color = Lvgl::Color.black
    @style_btn.border.opacity = Lvgl::Opacity::P20
    @style_btn.border.width = 2

    @style_btn.text.color = Lvgl::Color.black

    # Create a style for the pressed state.
    @style_button_pressed = Lvgl::Style.new
    @style_button_pressed.color.filter(Lvgl::Opacity::P20) do |_style, color, opacity|
      color.darken(opacity)
    end

    # Create a red style. Change only some colors.
    @style_button_red = Lvgl::Style.new
    @style_button_red.background.color = Lvgl::Palette::Red.main
    @style_button_red.background.gradient_color = Lvgl::Palette::Red.lighten(3)
  end

  # Create styles from scratch for buttons.
  def setup(screen)
    # Styles are already initialized when an instance of this class is made.

    # Create a button and use the new styles.
    btn = Lvgl::Button.new(screen)
    # Remove the styles coming from the theme.
    # Note that size and position are also stored as style properties,
    # so `Lvgl::Style#remove_all` will remove the set size and position too.
    btn.style.remove_all
    btn.position = {10, 10}
    btn.size = {120, 50}
    btn.style.add(@style_btn)
    btn.style.add(@style_button_pressed, selector: Lvgl::State::Pressed)

    # Add a label to the button.
    label = Lvgl::Label.new(btn)
    label.text = "Button"
    label.center

    # Create another button and use the red style too.
    btn2 = Lvgl::Button.new(screen)
    btn2.style.remove_all # Remove the styles coming from the theme.
    btn2.position = {10, 80}
    btn2.size = {120, 50}
    btn2.style.add(@style_btn)
    btn2.style.add(@style_button_red)
    btn2.style.add(@style_button_pressed, selector: Lvgl::State::Pressed)
    btn2.style.radius(Lvgl::Radius::Circle, selector: 0) # Add a local style too.

    label = Lvgl::Label.new(btn2)
    label.text = "Button 2"
    label.center
  end
end
