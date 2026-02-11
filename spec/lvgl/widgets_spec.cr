require "../spec_helper"

if Lvgl::SpecSupport::Harness.runtime_prerequisites_available?
  describe Lvgl::Widgets::Label do
    it "auto-starts runtime before .new" do
      Lvgl::SpecSupport::Harness.runtime_ready?.should be_true

      label = Lvgl::Widgets::Label.new(nil)

      label.should be_a(Lvgl::Widgets::Label)
      Lvgl::Runtime.initialized?.should be_true
    end

    it "creates label and updates text" do
      Lvgl::SpecSupport::Harness.runtime_ready?.should be_true

      label = Lvgl::Widgets::Label.new(nil)

      label.set_text("lvgl-crystal")
      label.raw.null?.should be_false
    end
  end

  describe Lvgl::Widgets::Button do
    it "auto-starts runtime before .new" do
      Lvgl::SpecSupport::Harness.runtime_ready?.should be_true

      button = Lvgl::Widgets::Button.new(nil)

      button.should be_a(Lvgl::Widgets::Button)
      Lvgl::Runtime.initialized?.should be_true
    end

    it "creates a button and sets size" do
      Lvgl::SpecSupport::Harness.runtime_ready?.should be_true

      button = Lvgl::Widgets::Button.new(nil)

      button.set_size(96, 44)
      button.raw.null?.should be_false
    end
  end
else
  describe "LVGL widget runtime specs" do
    pending "runtime widget specs skipped: #{Lvgl::SpecSupport::Harness.runtime_prerequisite_reason}"
  end
end
