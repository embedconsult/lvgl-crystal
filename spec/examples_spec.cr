require "./spec_helper"

describe "examples entrypoint" do
  it "runs each applet setup/loop/cleanup on headless backend with bounded ticks" do
    headless = Lvgl::Backend::HeadlessTestBackend.new
    unless headless.available?
      puts "Skipping examples entrypoint check: #{headless.unavailable_reason}"
      next
    end

    Lvgl::Applet.registry.each do |applet_class|
      applet = applet_class.new
      Lvgl::SpecSupport::Harness.with_headless_backend do |screen|
        applet.setup(screen)
        Lvgl::Runtime.scheduler.tick_inc(1_u32)
        Lvgl::Runtime.scheduler.timer_handler
        applet.loop(screen, Lvgl::Message.new(1_u64))
        applet.cleanup(screen)
      end
    end
  end
end
