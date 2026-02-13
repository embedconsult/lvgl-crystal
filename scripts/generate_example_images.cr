#!/usr/bin/env crystal
ENV["LVGL_NO_AUTORUN"] = "1"

require "../src/lvgl"
require "../src/examples/**"

def with_headless_backend(&)
  backend = Lvgl::Backend::HeadlessTestBackend.new
  raise backend.unavailable_reason || "headless backend unavailable" unless backend.available?

  backend.setup!
  begin
    yield Lvgl::Object.screen_active
  ensure
    backend.teardown!
    Lvgl::Runtime.shutdown if Lvgl::Runtime.initialized?
  end
end

Lvgl::Applet.registry.each do |applet_class|
  applet = applet_class.new
  puts "Generating docs/images/#{applet.source_basename}.png for #{applet.class_name}..."
  with_headless_backend do |screen|
    applet.setup(screen)
    Lvgl::Runtime.scheduler.timer_handler
    Lvgl::Snapshot.save_screen("docs/images/#{applet.source_basename}.png")
    puts "Generated docs/images/#{applet.source_basename}.png"
  end
end
