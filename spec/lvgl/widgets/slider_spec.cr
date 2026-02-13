require "../../spec_helper"

describe Lvgl::Widgets::Slider do
  it "creates a slider and exposes its value" do
    Lvgl::SpecSupport::Harness.with_runtime do
      slider = Lvgl::Widgets::Slider.new(nil)

      slider.value.should be_a(Int32)
      slider.raw.null?.should be_false
    end
  end
end
