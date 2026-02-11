require "../spec_helper"

describe Lvgl::Object do
  it "requires runtime initialization before create" do
    Lvgl::Runtime.deinit

    expect_raises(Exception, /Lvgl::Runtime\.init/) do
      Lvgl::Object.create(nil)
    end
  end

  it "requires runtime initialization before screen_active" do
    Lvgl::Runtime.deinit

    expect_raises(Exception, /Lvgl::Runtime\.init/) do
      Lvgl::Object.screen_active
    end
  end

  pending "creates top-level and child objects (requires LVGL display backend in CI)"
  pending "sets object size and centers object (requires LVGL display backend in CI)"
  pending "exposes raw pointer via #raw and #to_unsafe (requires LVGL display backend in CI)"
end
