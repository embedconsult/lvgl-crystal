require "../../spec_helper"

describe Lvgl::Widgets::Label do
  it "creates a label and supports text writer aliases" do
    Lvgl::SpecSupport::Harness.with_runtime do
      label = Lvgl::Widgets::Label.new(nil)

      label.set_text("lvgl-crystal")
      (label.text = "updated").should eq("updated")
      label.raw.null?.should be_false
    end
  end
end
