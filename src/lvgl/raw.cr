@[Link("lvgl", ldflags: "-L#{__DIR__}/../../lib/lvgl/build/crystal -Wl,-rpath,#{__DIR__}/../../lib/lvgl/build/crystal")]
lib LibLvgl
  # :nodoc:
  #
  # C declaration provenance: `lib/lvgl/src/lv_init.h` (`lv_init`, `lv_deinit`) and
  # `lib/lvgl/src/tick/lv_tick.h` + `lib/lvgl/src/misc/lv_timer.h`
  # (`lv_tick_inc`, `lv_timer_handler`).

  # Initialize the global LVGL runtime state.
  fun lv_init : Void

  # Advance LVGL's monotonic tick source by `tick_period` milliseconds.
  fun lv_tick_inc(tick_period : UInt32) : Void

  # Run due LVGL timers and return milliseconds until the next recommended call.
  fun lv_timer_handler : UInt32

  # Tear down LVGL global state.
  #
  # This symbol is present in LVGL 9.4's shared object build distributed with this
  # repository (`lib/lvgl/build/crystal/liblvgl.so`).
  fun lv_deinit : Void
end
