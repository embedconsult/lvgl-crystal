require "../../spec_helper"

describe Lvgl::Backend::FramebufferBackend do
  it "uses the framebuffer backend key" do
    Lvgl::Backend::FramebufferBackend.new.key.should eq("framebuffer")
  end

  it "reports actionable availability details" do
    backend = Lvgl::Backend::FramebufferBackend.new

    if backend.available?
      backend.unavailable_reason.should be_nil
    else
      reason = backend.unavailable_reason
      reason.should_not be_nil
      reason.should contain("LV_USE_LINUX_FBDEV=1") unless reason.nil?
      reason.should contain("LV_USE_EVDEV=1") unless reason.nil?
    end
  end
end
