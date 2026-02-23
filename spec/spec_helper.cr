require "spec"
require "../src/lvgl"
require "../src/examples"

# Default spec runs to the headless backend unless explicitly overridden.
# This avoids SDL runtime crashes in CI environments without an active
# desktop session (for example missing XDG_RUNTIME_DIR/display services).
ENV["LVGL_BACKEND"] ||= "headless"

require "./support/lvgl_harness"
