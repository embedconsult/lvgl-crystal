module Lvgl::Runtime
  # Initializes LVGL.
  #
  # LVGL docs: https://docs.lvgl.io/master/API/lv_init_h.html#_CPPv47lv_initv
  #
  # Source credit:
  # - Header: `lvgl/src/lv_init.h`
  # - Function: `lv_init`
  #
  # Behavior summary:
  # - Must be called before any other LVGL API.
  # - Access to LVGL APIs should be single-threaded unless explicitly synchronized.
  def self.init : Nil
    LibLvgl.lv_init
  end

  # Increments LVGL's internal millisecond tick counter.
  #
  # LVGL docs: https://docs.lvgl.io/master/API/tick/lv_tick_h.html#_CPPv410lv_tick_inc8uint32_t
  #
  # Source credit:
  # - Header: `lvgl/src/tick/lv_tick.h`
  # - Function: `lv_tick_inc`
  #
  # Behavior summary:
  # - Call from your system tick source with elapsed milliseconds.
  # - Access to LVGL APIs should be single-threaded unless explicitly synchronized.
  def self.tick_inc(ms : UInt32) : Nil
    LibLvgl.lv_tick_inc(ms)
  end

  # Runs LVGL timers and returns when the next call should be made.
  #
  # LVGL docs: https://docs.lvgl.io/master/details/integration/overview/timer_handler.html
  #
  # Source credit:
  # - Header: `lvgl/src/misc/lv_timer.h`
  # - Function: `lv_timer_handler`
  #
  # Behavior summary:
  # - Execute from your main loop or dedicated LVGL task context.
  # - Returns a millisecond delay hint for the next run.
  # - Access to LVGL APIs should be single-threaded unless explicitly synchronized.
  def self.timer_handler : UInt32
    LibLvgl.lv_timer_handler
  end

  # Deinitializes LVGL when supported by the linked `liblvgl.so`.
  #
  # LVGL docs: https://docs.lvgl.io/master/API/lv_init_h.html
  #
  # Source credit:
  # - Header: `lvgl/src/lv_init.h`
  # - Function: `lv_deinit`
  #
  # Behavior summary:
  # - Available when compiled with `-Dlvgl_has_deinit`.
  # - No-op when `lv_deinit` is not exported by the linked LVGL build.
  # - Access to LVGL APIs should be single-threaded unless explicitly synchronized.
  def self.deinit : Nil
    {% if flag?(:lvgl_has_deinit) %}
      LibLvgl.lv_deinit
    {% end %}
  end
end
