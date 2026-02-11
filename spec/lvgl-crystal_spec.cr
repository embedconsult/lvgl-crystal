require "./spec_helper"

describe Lvgl::Crystal do
  it "exposes a semantic version" do
    Lvgl::Crystal::VERSION.should match(/\A\d+\.\d+\.\d+\z/)
  end
end
