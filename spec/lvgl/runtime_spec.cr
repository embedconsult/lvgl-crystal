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
end
