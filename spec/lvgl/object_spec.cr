require "../spec_helper"

describe Lvgl::Object do
  it "tracks wrapper instance count" do
    Lvgl::Object.instance_count.should be >= 0
  end
end

if Lvgl::SpecSupport::Harness.runtime_prerequisites_available?
  describe Lvgl::Object do
    it "auto-starts runtime on first object creation" do
      Lvgl::SpecSupport::Harness.runtime_ready?.should be_true

      root = Lvgl::Object.new(nil)

      root.should be_a(Lvgl::Object)
      Lvgl::Runtime.initialized?.should be_true
    end

    it "auto-starts runtime when accessing screen_active" do
      Lvgl::SpecSupport::Harness.runtime_ready?.should be_true

      screen = Lvgl::Object.screen_active

      screen.should be_a(Lvgl::Object)
      Lvgl::Runtime.initialized?.should be_true
      screen.raw.null?.should be_false
    end

    it "creates top-level and child objects" do
      Lvgl::SpecSupport::Harness.runtime_ready?.should be_true

      parent = Lvgl::Object.new(nil)
      child = Lvgl::Object.new(parent)

      parent.raw.null?.should be_false
      child.raw.null?.should be_false
      child.parent.should eq(parent)
    end

    it "sets object size and centers object" do
      Lvgl::SpecSupport::Harness.runtime_ready?.should be_true

      object = Lvgl::Object.new(nil)

      object.set_size(120, 48)
      object.center
    end

    it "exposes raw pointer via #raw and #to_unsafe" do
      Lvgl::SpecSupport::Harness.runtime_ready?.should be_true

      object = Lvgl::Object.new(nil)

      object.raw.should eq(object.to_unsafe)
      object.raw.null?.should be_false
    end
  end
else
  describe Lvgl::Object do
    pending "runtime object specs skipped: #{Lvgl::SpecSupport::Harness.runtime_prerequisite_reason}"
  end
end
