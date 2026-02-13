require "./spec_helper"

describe Lvgl do
  it "exposes a semantic version" do
    Lvgl::VERSION.should match(/\A\d+\.\d+\.\d+\z/)
  end

  it "maps Lvgl::Result to LVGL's lv_result_t values" do
    Lvgl::Result::Invalid.value.should eq(0_u32)
    Lvgl::Result::Ok.value.should eq(1_u32)
  end
end

describe "LibLvgl" do
  it "links core LVGL lifecycle and timing symbols" do
    LibLvgl.lv_init
    LibLvgl.lv_deinit
  end
end

describe "Lvgl::Runtime" do
  it "wraps the same lifecycle API" do
    Lvgl::Runtime.start
    scheduler = Lvgl::Runtime.scheduler
    scheduler.tick_inc(1_u32)
    scheduler.timer_handler.should be_a(UInt32)
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
