require "../../spec_helper"

describe Lvgl::Backend::WaylandBackend do
  it "uses the wayland backend key" do
    Lvgl::Backend::WaylandBackend.new.key.should eq("wayland")
  end

  it "reports actionable availability details" do
    backend = Lvgl::Backend::WaylandBackend.new

    if backend.available?
      backend.unavailable_reason.should be_nil
    else
      reason = backend.unavailable_reason
      reason.should_not be_nil
      reason.should contain("LV_USE_WAYLAND=1") unless reason.nil?
    end
  end
end
