require "../spec_helper"

describe Lvgl::Style do
  it "supports expressive style composition and native style attachment" do
    Lvgl::SpecSupport::Harness.with_runtime do
      base = Lvgl::Style.new
      base.radius = 10
      base.radius=(10)
      base.background.opacity = Lvgl::Opacity::Cover
      base.background.opacity=(Lvgl::Opacity::Cover)
      base.background.color = Lvgl::Palette::Grey.lighten(3)
      base.background.color=(Lvgl::Palette::Grey.lighten(3))
      base.background.gradient_color = Lvgl::Palette::Grey.main
      base.background.gradient_color=(Lvgl::Palette::Grey.main)
      base.background.gradient_direction = Lvgl::GradientDirection::Vertical
      base.background.gradient_direction=(Lvgl::GradientDirection::Vertical)
      base.border.color = Lvgl::Color.black
      base.border.color=(Lvgl::Color.black)
      base.border.opacity = Lvgl::Opacity::P20
      base.border.opacity=(Lvgl::Opacity::P20)
      base.border.width = 2
      base.border.width=(2)
      base.text.color = Lvgl::Color.black
      base.text.color=(Lvgl::Color.black)
      base.background
        .opacity(Lvgl::Opacity::Cover)
        .color(Lvgl::Palette::Grey.lighten(3))
        .gradient_color(Lvgl::Palette::Grey.main)
        .gradient_direction(Lvgl::GradientDirection::Vertical)
      base.border
        .color(Lvgl::Color.black)
        .opacity(Lvgl::Opacity::P20)
        .width(2)
      base.radius(Lvgl::Radius::Circle)

      # Extended property coverage without attaching these pointers to a live object.
      extended = Lvgl::Style.new
      extended.background.gradient_main_stop=(10)
      extended.background.gradient_stop=(240)
      extended.background.gradient_main_opacity=(Lvgl::Opacity::P20)
      extended.background.gradient_opacity=(Lvgl::Opacity::Cover)
      extended.background.image_source=(Pointer(Void).null)
      extended.background.image_opacity=(Lvgl::Opacity::P20)
      extended.background.image_recolor=(Lvgl::Palette::Red.main)
      extended.background.image_recolor_opacity=(Lvgl::Opacity::P20)
      extended.background.image_tiled=(true)
      extended.background.gradient_main_stop(10)
      extended.background.gradient_stop(240)
      extended.background.gradient_main_opacity(Lvgl::Opacity::P20)
      extended.background.gradient_opacity(Lvgl::Opacity::Cover)
      extended.background.image_source(Pointer(Void).null)
      extended.background.image_opacity(Lvgl::Opacity::P20)
      extended.background.image_recolor(Lvgl::Palette::Red.main)
      extended.background.image_recolor_opacity(Lvgl::Opacity::P20)
      extended.background.image_tiled(false)
      extended.border.side=(Lvgl::BorderSide::Full)
      extended.border.post=(false)
      extended.border.side(Lvgl::BorderSide::Full)
      extended.border.post(false)
      extended.outline.width=(2)
      extended.outline.color=(Lvgl::Palette::Grey.main)
      extended.outline.opacity=(Lvgl::Opacity::P20)
      extended.outline.pad=(2)
      extended.outline.width(2).color(Lvgl::Palette::Grey.main).opacity(Lvgl::Opacity::P20).pad(2)
      extended.shadow.width=(12)
      extended.shadow.offset_x=(2)
      extended.shadow.offset_y=(3)
      extended.shadow.spread=(1)
      extended.shadow.color=(Lvgl::Palette::Grey.main)
      extended.shadow.opacity=(Lvgl::Opacity::P20)
      extended.shadow.width(12).offset_x(2).offset_y(3).spread(1).color(Lvgl::Palette::Grey.main).opacity(Lvgl::Opacity::P20)
      extended.line.width=(2)
      extended.line.dash_width=(4)
      extended.line.dash_gap=(2)
      extended.line.rounded=(true)
      extended.line.color=(Lvgl::Palette::Grey.main)
      extended.line.opacity=(Lvgl::Opacity::Cover)
      extended.line.width(2).dash_width(4).dash_gap(2).rounded(true).color(Lvgl::Palette::Grey.main).opacity(Lvgl::Opacity::Cover)
      extended.arc.width=(3)
      extended.arc.rounded=(true)
      extended.arc.color=(Lvgl::Palette::Red.main)
      extended.arc.opacity=(Lvgl::Opacity::Cover)
      extended.arc.image_source=(Pointer(Void).null)
      extended.arc.width(3).rounded(true).color(Lvgl::Palette::Red.main).opacity(Lvgl::Opacity::Cover).image_source(Pointer(Void).null)
      extended.text.opacity=(Lvgl::Opacity::Cover)
      extended.text.letter_space=(1)
      extended.text.line_space=(2)
      extended.text.decor=(Lvgl::TextDecor::Underline)
      extended.text.align=(Lvgl::TextAlign::Center)
      extended.text.opacity(Lvgl::Opacity::Cover).letter_space(1).line_space(2).decor(Lvgl::TextDecor::Underline).align(Lvgl::TextAlign::Center)
      extended.text.outline.color=(Lvgl::Palette::Red.main)
      extended.text.outline.width=(1)
      extended.text.outline.opacity=(Lvgl::Opacity::Cover)
      extended.text.outline.color(Lvgl::Palette::Red.main).width(1).opacity(Lvgl::Opacity::Cover)
      extended.layout.id=(0_u16)
      extended.layout.base_direction=(Lvgl::BaseDirection::Ltr)
      extended.layout.id(0_u16).base_direction(Lvgl::BaseDirection::Ltr)
      extended.flex.flow=(Lvgl::FlexFlow::RowWrap)
      extended.flex.main_place=(Lvgl::FlexAlign::Center)
      extended.flex.cross_place=(Lvgl::FlexAlign::Start)
      extended.flex.track_place=(Lvgl::FlexAlign::SpaceBetween)
      extended.flex.grow=(1_u8)
      extended.flex.flow(Lvgl::FlexFlow::RowWrap).main_place(Lvgl::FlexAlign::Center).cross_place(Lvgl::FlexAlign::Start).track_place(Lvgl::FlexAlign::SpaceBetween).grow(1_u8)
      extended.grid.column_descriptors=(Pointer(Int32).null)
      extended.grid.row_descriptors=(Pointer(Int32).null)
      extended.grid.column_align=(Lvgl::GridAlign::Center)
      extended.grid.row_align=(Lvgl::GridAlign::SpaceAround)
      extended.grid.cell_column_pos=(0)
      extended.grid.cell_column_span=(1)
      extended.grid.cell_x_align=(Lvgl::GridAlign::Stretch)
      extended.grid.cell_row_pos=(0)
      extended.grid.cell_row_span=(1)
      extended.grid.cell_y_align=(Lvgl::GridAlign::Start)
      extended.grid.column_descriptors(Pointer(Int32).null).row_descriptors(Pointer(Int32).null).column_align(Lvgl::GridAlign::Center).row_align(Lvgl::GridAlign::SpaceAround)
      extended.grid.cell_column_pos(0).cell_column_span(1).cell_x_align(Lvgl::GridAlign::Stretch).cell_row_pos(0).cell_row_span(1).cell_y_align(Lvgl::GridAlign::Start)
      extended.transition.descriptor=(Pointer(LibLvgl::LvStyleTransitionDscT).null)
      extended.transition.animation=(Pointer(LibLvgl::LvAnimT).null)
      extended.transition.duration=(120_u32)
      extended.transition.blend_mode=(Lvgl::BlendMode::Normal)
      extended.transition.descriptor(Pointer(LibLvgl::LvStyleTransitionDscT).null).animation(Pointer(LibLvgl::LvAnimT).null).duration(120_u32).blend_mode(Lvgl::BlendMode::Normal)

      pressed = Lvgl::Style.new
      pressed.color.filter do |_style, color, opacity|
        color.darken(opacity)
      end

      button = Lvgl::Button.new(nil)
      button.style.remove_all
      button.position = {10, 10}
      button.position=({10, 10})
      button.size = {120, 50}
      base.apply_to(button, Lvgl.style_selector)
      button.style.add(base)
      button.style.add(pressed, selector: Lvgl::State::Pressed)
      button.style.add(pressed, selector: Lvgl::Part::Main | Lvgl::State::Pressed)
      button.add_style(base, selector: Lvgl::State::Pressed)
      button.add_state(Lvgl::State::Pressed)
      button.remove_state(Lvgl::State::Pressed)
      button.style.radius(Lvgl::Radius::Circle, selector: 0)
      button.set_style_bg_grad_dir(Lvgl::GradientDirection::Vertical)
      button.get_style_prop(Lvgl::Part::Main, Lvgl::StyleProp::BgColor)

      button.raw.null?.should be_false
    end
  end

  it "applies pressed color filters when selector state is active" do
    Lvgl::SpecSupport::Harness.with_runtime do
      base = Lvgl::Style.new
      base.background.color = Lvgl::Palette::Red.main
      pressed = Lvgl::Style.new
      pressed.color.filter(Lvgl::Opacity::P20) do |_style, color, opacity|
        color.darken(opacity)
      end

      button = Lvgl::Button.new(nil)
      button.style.remove_all
      button.style.add(base)
      button.style.add(pressed, selector: Lvgl::State::Pressed)

      base_color = button.get_style_prop(Lvgl::Part::Main, Lvgl::StyleProp::BgColor)
      default_filtered = button.apply_style_color_filter(Lvgl::Part::Main, base_color)

      button.add_state(Lvgl::State::Pressed)
      pressed_color = button.get_style_prop(Lvgl::Part::Main, Lvgl::StyleProp::BgColor)
      pressed_filtered = button.apply_style_color_filter(Lvgl::Part::Main, pressed_color)
      button.remove_state(Lvgl::State::Pressed)

      default_raw = default_filtered.color
      pressed_raw = pressed_filtered.color

      {default_raw.red, default_raw.green, default_raw.blue}.should_not eq(
        {pressed_raw.red, pressed_raw.green, pressed_raw.blue}
      )
    end
  end

  it "exposes color convenience helpers" do
    Lvgl::Color.black.should be_a(Lvgl::Color)
    Lvgl::Color.black.darken.should be_a(Lvgl::Color)
    Lvgl::GradientDirection::Vertical.to_grad_dir.should eq(Lvgl::GradDir::Ver)
  end

  it "can reset style descriptors for reuse" do
    style = Lvgl::Style.new
    style.reset
  end
end
