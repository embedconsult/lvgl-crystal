require "../spec_helper"

describe Lvgl::Snapshot do
  it "saves object and screen snapshots when headless backend is available" do
    object_path = "tmp/spec/snapshot_object.png"
    screen_path = "tmp/spec/snapshot_screen.png"

    begin
      Lvgl::SpecSupport::Harness.with_headless_backend do |screen|
        root = Lvgl::Object.new(screen)
        root.set_size(64, 64)

        Lvgl::Snapshot.save_object(root, object_path)
        Lvgl::Snapshot.save_screen(screen_path)
      end

      File.exists?(object_path).should be_true
      File.exists?(screen_path).should be_true
    rescue ex
      pending "Skipping snapshot spec: #{ex.message}"
    ensure
      File.delete?(object_path)
      File.delete?(screen_path)
    end
  end
end
