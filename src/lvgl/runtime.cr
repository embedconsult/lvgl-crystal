require "./raw"
require "./scheduler"

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
# - On shutdown, stop input/display drivers first, then call `shutdown` once.
#
# Example pseudo-flow:
#
# ```text
# app start -> Runtime.start
# timer fiber: every 1 ms -> Runtime.tick_inc(1)
# ui fiber: loop { wait = Runtime.timer_handler; sleep(wait.milliseconds) }
# app stop -> Runtime.shutdown
# ```
module Lvgl::Runtime
  @@state_lock = Mutex.new
  @@initialized = Atomic(Int32).new(0)
  @@scheduler : Lvgl::Scheduler? = nil
  @@custom_timer_handler : (-> UInt32)? = nil

  # Returns whether this process has successfully called `Runtime.start` and has
  # not yet called `Runtime.shutdown`.
  #
  # This flag is useful when higher-level wrappers need to guard object creation
  # so LVGL APIs are not called before global initialization.
  def self.initialized? : Bool
    @@initialized.get == 1
  end

  # Source credit:
  # - Header: `lib/lvgl/src/lv_init.h`
  # - Function: `lv_init`
  # - LVGL docs: https://docs.lvgl.io/9.4/API/lv_init.html
  #
  # Initializes LVGL global state and Crystal-side runtime resources.
  #
  # - This is the preferred API for app code.
  # - Call before creating LVGL objects, displays, input devices, themes, or styles.
  # - Must execute on the same synchronized execution context used for later LVGL calls.
  # - Re-initialization without `shutdown` is undefined and should be avoided.
  #
  # This wrapper is idempotent: if the runtime is already initialized,
  # calling `start` again is a no-op.
  #
  # The transition is guarded by a global lock/atomic state so concurrent fibers
  # cannot initialize LVGL twice.
  def self.start : Nil
    @@state_lock.synchronize do
      return if initialized?

      Log.debug { "Calling LibLvgl.lv_init" }
      LibLvgl.lv_init
      @@initialized.set(1)
    end
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
    scheduler.tick_inc(ms)
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
    handler = @@state_lock.synchronize { @@custom_timer_handler }
    return handler.call if handler

    scheduler.timer_handler
  end

  # Returns the process-global scheduler used by runtime-level helpers.
  #
  # Higher-level app code may also create and own dedicated `Lvgl::Scheduler`
  # instances directly.
  def self.scheduler : Lvgl::Scheduler
    @@state_lock.synchronize do
      @@scheduler ||= Lvgl::Scheduler.new
    end
  end

  # Installs a backend-specific timer handler used by `Runtime.timer_handler`.
  #
  # Backends such as Wayland can wrap LVGL timer processing to integrate
  # platform event dispatch.
  def self.install_timer_handler(&block : -> UInt32) : Nil
    Log.debug { "Installing custom timer handler" }
    @@state_lock.synchronize do
      @@custom_timer_handler = block
    end
  end

  # Restores default runtime timer handling (`lv_timer_handler`).
  def self.reset_timer_handler : Nil
    Log.debug { "Restoring timer handler" }
    @@state_lock.synchronize do
      @@custom_timer_handler = nil
    end
  end

  # Source credit:
  # - Header: `lib/lvgl/src/lv_init.h`
  # - Function: `lv_deinit`
  # - LVGL docs: https://docs.lvgl.io/9.4/API/lv_init.html
  #
  # Deinitializes LVGL global state.
  #
  # - Shut down display/input backend threads and callbacks before calling this.
  # - Do not call other LVGL APIs after shutdown unless you start again.
  # - In managed app lifecycles, pair one successful `start` with one final `shutdown`.
  #
  # This wrapper is idempotent: if LVGL is already deinitialized, this method is
  # a no-op.
  #
  # Calls `lv_deinit` when LVGL is currently initialized, otherwise no-ops.
  # Prefer explicit shutdown in app lifecycle code rather than relying on
  # process teardown.
  def self.shutdown : Nil
    @@state_lock.synchronize do
      return unless initialized?

      Log.debug { "Calling LibLvgl.lv_deinit" }
      LibLvgl.lv_deinit
      @@initialized.set(0)
      @@custom_timer_handler = nil
    end
  end
end
