require "../spec_helper"

describe Lvgl::Widgets::Label do
  it "requires runtime initialization before .new" do
    Lvgl::Runtime.deinit

    expect_raises(Exception, /Lvgl::Runtime\.init/) do
      Lvgl::Widgets::Label.new(nil)
    end
  end

  pending "creates label and updates text (requires LVGL display backend in CI)"
end

describe Lvgl::Widgets::Button do
  it "requires runtime initialization before .new" do
    Lvgl::Runtime.deinit

    expect_raises(Exception, /Lvgl::Runtime\.init/) do
      Lvgl::Widgets::Button.new(nil)
    end
  end

  pending "creates a button and sets size (requires LVGL display backend in CI)"
end
