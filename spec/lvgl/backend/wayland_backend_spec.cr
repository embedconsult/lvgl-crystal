require "../../spec_helper"

describe Lvgl::Backend::WaylandBackend do
  it "uses the wayland backend key" do
    Lvgl::Backend::WaylandBackend.new.key.should eq("wayland")
  end

  it "matches headless backend availability" do
    wayland = Lvgl::Backend::WaylandBackend.new
    headless = Lvgl::Backend::HeadlessTestBackend.new

    wayland.available?.should eq(headless.available?)
  end
end
