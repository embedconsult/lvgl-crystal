require "../spec_helper"

describe Lvgl::Object do
  it "tracks wrapper instance count" do
    Lvgl::Object.instance_count.should be >= 0
  end

  pending "auto-starts runtime on first object creation (requires LVGL display backend in CI)"
  pending "auto-starts runtime when accessing screen_active (requires LVGL display backend in CI)"
  pending "creates top-level and child objects (requires LVGL display backend in CI)"
  pending "sets object size and centers object (requires LVGL display backend in CI)"
  pending "exposes raw pointer via #raw and #to_unsafe (requires LVGL display backend in CI)"
end
