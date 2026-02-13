require "../spec_helper"

describe Lvgl::Backend do
  it "uses the platform default backend when LVGL_BACKEND is unset" do
    previous = ENV["LVGL_BACKEND"]?
    ENV.delete("LVGL_BACKEND")

    begin
      {% if flag?(:darwin) %}
        Lvgl::Backend.from_env.should be_a(Lvgl::Backend::MacosBackend)
      {% else %}
        Lvgl::Backend.from_env.should be_a(Lvgl::Backend::SdlBackend)
      {% end %}
    ensure
      if previous
        ENV["LVGL_BACKEND"] = previous
      else
        ENV.delete("LVGL_BACKEND")
      end
    end
  end

  it "selects macos backend when LVGL_BACKEND=macos" do
    previous = ENV["LVGL_BACKEND"]?
    ENV["LVGL_BACKEND"] = "macos"

    begin
      Lvgl::Backend.from_env.should be_a(Lvgl::Backend::MacosBackend)
    ensure
      if previous
        ENV["LVGL_BACKEND"] = previous
      else
        ENV.delete("LVGL_BACKEND")
      end
    end
  end
end
