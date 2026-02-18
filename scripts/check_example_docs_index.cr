#!/usr/bin/env crystal
ENV["LVGL_NO_AUTORUN"] = "1"

require "../src/examples"

Examples.validate_docs_metadata!
puts "Verified applet metadata annotations and macro-generated docs index"
