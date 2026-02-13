require "../../spec_helper"

describe Lvgl::Backend::MacosBackend do
  it "uses the macos backend key" do
    Lvgl::Backend::MacosBackend.new.key.should eq("macos")
  end

  it "reports actionable availability details" do
    backend = Lvgl::Backend::MacosBackend.new

    if backend.available?
      backend.unavailable_reason.should be_nil
    else
      reason = backend.unavailable_reason
      reason.should_not be_nil
      reason.should contain("LV_USE_SDL=1") unless reason.nil?
    end
  end
end
