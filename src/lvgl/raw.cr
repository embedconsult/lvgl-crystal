@[Link("lvgl")]
lib LibLvgl
  # Initializes the LVGL core and must be called before using any other LVGL API.
  fun lv_init : Void

  # Advances LVGL's internal tick counter by the given number of milliseconds.
  fun lv_tick_inc(ms : UInt32) : Void

  # Runs pending LVGL timers and returns the number of milliseconds until the next timer run.
  fun lv_timer_handler : UInt32

  {% if flag?(:lvgl_has_deinit) %}
    # Deinitializes the LVGL core.
    #
    # Enable with `-Dlvgl_has_deinit` when `lv_deinit` is exported by your installed `liblvgl.so`.
    fun lv_deinit : Void
  {% end %}
end
