#!/usr/bin/env crystal
ENV["LVGL_NO_AUTORUN"] = "1"

require "../src/examples"

# CI check: validate that every registered applet is annotated and represented
# in the macro-collected docs entry set.
Examples.validate_docs_metadata!
puts "Verified applet metadata annotations and macro-generated docs index"
