require "../spec_helper"

describe Lvgl::Runtime do
  it "provides a singleton scheduler" do
    first = Lvgl::Runtime.scheduler
    second = Lvgl::Runtime.scheduler

    first.should be(second)
  end

  it "supports idempotent start and shutdown" do
    Lvgl::SpecSupport::Harness.with_runtime do
      Lvgl::Runtime.initialized?.should be_true

      Lvgl::Runtime.start
      Lvgl::Runtime.initialized?.should be_true

      Lvgl::Runtime.shutdown
      Lvgl::Runtime.initialized?.should be_false

      Lvgl::Runtime.shutdown
      Lvgl::Runtime.initialized?.should be_false

      Lvgl::Runtime.start
      Lvgl::Runtime.initialized?.should be_true
    end
  end

  it "allows backend-specific timer handler overrides" do
    begin
      Lvgl::Runtime.install_timer_handler { 42_u32 }
      Lvgl::Runtime.timer_handler.should eq(42_u32)
    ensure
      Lvgl::Runtime.reset_timer_handler
    end
  end
end
