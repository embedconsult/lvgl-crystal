require "./raw"

# High-level lifecycle wrapper for the minimal LVGL event-loop API needed by
# Crystal examples.
#
# ![LVGL data flow diagram (LVGL docs)](https://docs.lvgl.io/9.4/_images/intro_data_flow.png)
#
# *Image credit:* LVGL project docs, "Data flow" diagram, version 9.4.
#
# ## Concurrency preconditions
#
# - LVGL keeps mutable global state and is **not** generally safe for unrestricted
#   concurrent calls.
# - In Crystal, treat LVGL calls as a single critical section (for example: a
#   dedicated UI fiber plus channel-based command dispatch, or a global Mutex
#   around every LVGL entry point).
# - Only use multi-threaded access when your integration explicitly synchronizes
#   LVGL and all backend I/O callbacks.
#
# ## Typical fibers-based integration loop
#
# - Create one "UI fiber" that owns LVGL calls.
# - Have timing code call `tick_inc(1_u32)` each millisecond (or a coarser fixed
#   tick that matches your scheduler resolution).
# - In the UI loop, call `timer_handler`, then sleep roughly the returned number
#   of milliseconds (bounded to a small maximum to keep responsiveness).
# - On shutdown, stop input/display drivers first, then call `deinit` once.
#
# Example pseudo-flow:
#
# ```text
# app start -> Runtime.init
# timer fiber: every 1 ms -> Runtime.tick_inc(1)
# ui fiber: loop { wait = Runtime.timer_handler; sleep(wait.milliseconds) }
# app stop -> Runtime.deinit
# ```
module Lvgl::Runtime
  # Source credit:
  # - Header: `lib/lvgl/src/lv_init.h`
  # - Function: `lv_init`
  # - LVGL docs: https://docs.lvgl.io/9.4/API/lv_init.html
  #
  # Initializes LVGL global state.
  #
  # - Call once before creating LVGL objects, displays, input devices, themes, or styles.
  # - Must execute on the same synchronized execution context used for later LVGL calls.
  # - Re-initialization without `deinit` is undefined and should be avoided.
  def self.init : Nil
    LibLvgl.lv_init
  end

  # Source credit:
  # - Header: `lib/lvgl/src/tick/lv_tick.h`
  # - Function: `lv_tick_inc`
  # - LVGL docs: https://docs.lvgl.io/9.4/API/tick/lv_tick.html
  #
  # Advances LVGL's internal tick counter by `ms` milliseconds.
  #
  # - Usually called by a high-frequency timer source (1ms is common).
  # - LVGL timers/animations derive elapsed-time behavior from this clock.
  # - Call frequency can be lower, but animation smoothness and timer precision will follow it.
  def self.tick_inc(ms : UInt32) : Nil
    LibLvgl.lv_tick_inc(ms)
  end

  # Source credit:
  # - Header: `lib/lvgl/src/misc/lv_timer.h`
  # - Function: `lv_timer_handler`
  # - LVGL docs: https://docs.lvgl.io/9.4/API/misc/lv_timer.html
  #
  # Processes expired LVGL timers and scheduled work.
  #
  # - Returns milliseconds until the next recommended `timer_handler` call.
  # - Run this frequently from the same synchronized LVGL execution context.
  # - Typical UI loops sleep for the returned time (often clamped to a max bound).
  def self.timer_handler : UInt32
    LibLvgl.lv_timer_handler
  end

  # Source credit:
  # - Header: `lib/lvgl/src/lv_init.h`
  # - Function: `lv_deinit`
  # - LVGL docs: https://docs.lvgl.io/9.4/API/lv_init.html
  #
  # Deinitializes LVGL global state.
  #
  # - Shut down display/input backend threads and callbacks before calling this.
  # - Do not call other LVGL APIs after deinit unless you initialize again.
  # - In managed app lifecycles, pair one successful `init` with one final `deinit`.
  def self.deinit : Nil
    LibLvgl.lv_deinit
  end
end
