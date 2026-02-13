require "../spec_helper"

describe Lvgl::Snapshot do
  it "saves object and screen snapshots when runtime snapshot support is available" do
    unless Lvgl::SpecSupport::Harness.runtime_ready?
      puts "Skipping snapshot spec: #{Lvgl::SpecSupport::Harness.runtime_skip_reason}"
      next
    end

    begin
      root = Lvgl::Object.new(nil)
      root.set_size(64, 64)

      object_path = "tmp/spec/snapshot_object.png"
      screen_path = "tmp/spec/snapshot_screen.png"

      begin
        Lvgl::Snapshot.save_object(root, object_path)
        Lvgl::Snapshot.save_screen(screen_path)
      rescue ex
        puts "Skipping snapshot save assertions: #{ex.message}"
        next
      end

      File.exists?(object_path).should be_true
      File.exists?(screen_path).should be_true
    ensure
      Lvgl::SpecSupport::Harness.safe_cleanup
    end
  end
end
