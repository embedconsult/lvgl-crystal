#!/usr/bin/env crystal
ENV["LVGL_NO_AUTORUN"] = "1"

require "file_utils"
require "../src/examples"

# Generates example screenshots from applet metadata annotations.

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

Examples.validate_docs_metadata!

Examples.docs_entries.each do |entry|
  puts "Generating #{entry.docs_output_path} for #{entry.class_name}..."
  FileUtils.mkdir_p(File.dirname(entry.docs_output_path))

  with_headless_backend do |screen|
    applet = entry.applet_class.new
    applet.setup(screen)
    Lvgl::Runtime.scheduler.timer_handler
    Lvgl::Snapshot.save_screen(entry.docs_output_path)
    puts "Generated #{entry.docs_output_path}"
  end
end

puts "Verified applet metadata annotations and macro-generated docs index"
