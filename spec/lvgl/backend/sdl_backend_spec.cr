require "../../spec_helper"

describe Lvgl::Backend::SdlBackend do
  it "uses the sdl backend key" do
    Lvgl::Backend::SdlBackend.new.key.should eq("sdl")
  end

  it "reports actionable availability details" do
    backend = Lvgl::Backend::SdlBackend.new

    if backend.available?
      backend.unavailable_reason.should be_nil
    else
      backend.unavailable_reason.should_not be_nil
      backend.unavailable_reason.not_nil!.should contain("LV_USE_SDL=1")
    end
  end
end
