require "./spec_helper"

describe Lvgl::Crystal do
  it "exposes a semantic version" do
    Lvgl::Crystal::VERSION.should match(/\A\d+\.\d+\.\d+\z/)
  end
end

describe "LibLvgl" do
  it "links core LVGL lifecycle and timing symbols" do
    LibLvgl.lv_init
    LibLvgl.lv_tick_inc(1_u32)
    LibLvgl.lv_timer_handler.should be_a(UInt32)
    LibLvgl.lv_deinit
  end
end

describe "Lvgl::Runtime" do
  it "wraps the same lifecycle API" do
    Lvgl::Runtime.start
    Lvgl::Runtime.tick_inc(1_u32)
    Lvgl::Runtime.timer_handler.should be_a(UInt32)
    Lvgl::Runtime.shutdown
  end

  it "keeps start and shutdown idempotent" do
    Lvgl::Runtime.start
    Lvgl::Runtime.start
    Lvgl::Runtime.initialized?.should be_true

    Lvgl::Runtime.shutdown
    Lvgl::Runtime.shutdown
    Lvgl::Runtime.initialized?.should be_false
  end
end
