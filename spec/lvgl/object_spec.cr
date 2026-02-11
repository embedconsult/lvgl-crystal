require "../spec_helper"

describe Lvgl::Object do
  it "tracks wrapper instance count" do
    Lvgl::Object.instance_count.should be >= 0
  end

  if Lvgl::SpecSupport::Harness.runtime_ready?
    it "auto-starts runtime on first object creation" do
      Lvgl::Runtime.shutdown

      root = Lvgl::Object.new(nil)

      root.should be_a(Lvgl::Object)
      Lvgl::Runtime.initialized?.should be_true
    end

    it "auto-starts runtime when accessing screen_active" do
      Lvgl::Runtime.shutdown

      screen = Lvgl::Object.screen_active

      screen.should be_a(Lvgl::Object)
      Lvgl::Runtime.initialized?.should be_true
      screen.raw.null?.should be_false
    end

    it "creates top-level and child objects" do
      parent = Lvgl::Object.new(nil)
      child = Lvgl::Object.new(parent)

      parent.raw.null?.should be_false
      child.raw.null?.should be_false
      child.parent.should eq(parent)
    end

    it "sets object size and centers object" do
      object = Lvgl::Object.new(nil)

      object.set_size(120, 48)
      object.center
    end

    it "exposes raw pointer via #raw and #to_unsafe" do
      object = Lvgl::Object.new(nil)

      object.raw.should eq(object.to_unsafe)
      object.raw.null?.should be_false
    end
  else
    pending "runtime object specs skipped: #{Lvgl::SpecSupport::Harness.runtime_skip_reason}"
  end
end
