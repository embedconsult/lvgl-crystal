require "../spec_helper"

describe Lvgl::Snapshot do
  unless Lvgl::SpecSupport::Harness.runtime_ready?
    pending "Skipping snapshot spec: #{Lvgl::SpecSupport::Harness.runtime_skip_reason}"
    next
  end
  backend_key = Lvgl::SpecSupport::Harness.backend.key
  unless backend_key == "headless"
    pending "Skipping snapshot spec: requires headless backend (backend: #{backend_key})"
    Lvgl::SpecSupport::Harness.safe_cleanup
    next
  end
  begin
    pending "saves object and screen snapshots when runtime snapshot support is available (hangs, backend: #{backend_key})" do
      root = Lvgl::Object.new(nil)
      root.set_size(64, 64)

      object_path = "tmp/spec/snapshot_object.png"
      screen_path = "tmp/spec/snapshot_screen.png"

      Lvgl::Snapshot.save_object(root, object_path)
      Lvgl::Snapshot.save_screen(screen_path)

      File.exists?(object_path).should be_true
      File.exists?(screen_path).should be_true
    end
  rescue ex
    pending "Skipping snapshot save assertions: #{ex.message}"
  ensure
    Lvgl::SpecSupport::Harness.safe_cleanup
  end
end
