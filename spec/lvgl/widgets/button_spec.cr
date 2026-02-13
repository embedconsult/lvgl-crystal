require "../../spec_helper"

describe Lvgl::Widgets::Button do
  it "creates a button and delegates size setter" do
    Lvgl::SpecSupport::Harness.with_runtime do
      button = Lvgl::Widgets::Button.new(nil)

      button.set_size(96, 44)
      button.raw.null?.should be_false
    end
  end
end
