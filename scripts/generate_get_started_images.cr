#!/usr/bin/env crystal
ENV["LVGL_NO_AUTORUN"] = "1"

require "../src/lvgl"
require "../src/examples/get_started/lv_example_get_started_1"
require "../src/examples/get_started/lv_example_get_started_2"

example = ARGV[0]? || "all"

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

def save_example_1
  with_headless_backend do |screen|
    ExampleGetStarted1.new.setup(screen)
    Lvgl::Runtime.scheduler.timer_handler
    Lvgl::Snapshot.save_object(screen[0], "docs/images/lv_example_get_started_1.png")
  end
  puts "Generated docs/images/lv_example_get_started_1.png"
end

def save_example_2
  with_headless_backend do |screen|
    ExampleGetStarted2.new.setup(screen)
    Lvgl::Runtime.scheduler.timer_handler
    Lvgl::Snapshot.save_object(screen[0], "docs/images/lv_example_get_started_2.png")
  end
  puts "Generated docs/images/lv_example_get_started_2.png"
end

case example
when "1"
  save_example_1
when "2"
  save_example_2
when "all"
  save_example_1
  save_example_2
else
  abort "Unknown example '#{example}'. Use '1', '2', or 'all'."
end
