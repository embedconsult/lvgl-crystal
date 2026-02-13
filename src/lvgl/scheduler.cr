require "channel"

require "./raw"

# Minimal LVGL event-loop helper.
#
# ## Summary
# Coordinates tick progression, timer handling, and queued UI work.
#
# ## Notes
#
# - Exactly one fiber (the "UI fiber") owns LVGL calls and LVGL object mutation.
# - Non-UI fibers must never call LVGL APIs directly and must never mutate
#   `Lvgl::Object`/widget instances directly.
# - Non-UI fibers marshal UI work through `#schedule`; the UI fiber executes
#   those closures via `#drain_scheduled_work`/`#step`.
# - Violating this contract can race LVGL global state and object internals,
#   leading to undefined behavior (flicker, memory corruption, or crashes).
class Lvgl::Scheduler
  DEFAULT_TICK_PERIOD_MS =  1_u32
  DEFAULT_MAX_SLEEP_MS   = 10_u32
  DEFAULT_QUEUE_CAPACITY =     64
  ZERO_MS                =  0_u32
  CLOSED_FLAG            =      1
  OPEN_FLAG              =      0

  @queue : Channel(Proc(Nil))
  @closed = Atomic(Int32).new(OPEN_FLAG)

  getter tick_period_ms : UInt32
  getter max_sleep_ms : UInt32

  def initialize(
    @tick_period_ms : UInt32 = DEFAULT_TICK_PERIOD_MS,
    @max_sleep_ms : UInt32 = DEFAULT_MAX_SLEEP_MS,
    queue_capacity : Int32 = DEFAULT_QUEUE_CAPACITY,
  )
    raise ArgumentError.new("tick_period_ms must be > 0") if @tick_period_ms == ZERO_MS
    raise ArgumentError.new("max_sleep_ms must be > 0") if @max_sleep_ms == ZERO_MS
    raise ArgumentError.new("queue_capacity must be >= 0") if queue_capacity < 0

    @queue = Channel(Proc(Nil)).new(queue_capacity)
  end

  # Enqueue UI work from any non-UI fiber.
  #
  # The block must contain all LVGL object mutation needed for the update,
  # and will execute on the UI fiber when `drain_scheduled_work` is called.
  def schedule(&block : -> Nil) : Nil
    raise "scheduler is closed" if closed?

    @queue.send(block)
  end

  # UI-fiber-only: advances LVGL's monotonic tick source.
  def tick_inc(ms : UInt32 = @tick_period_ms) : Nil
    LibLvgl.lv_tick_inc(ms)
  end

  # UI-fiber-only: runs due LVGL timers and returns next recommended delay.
  def timer_handler : UInt32
    LibLvgl.lv_timer_handler
  end

  # UI-fiber-only: runs pending cross-fiber work items without blocking.
  def drain_scheduled_work : Int32
    processed = 0

    loop do
      select
      when received_task = @queue.receive
        task = received_task
      else
        break
      end

      task.call unless task.nil?
      processed += 1
    end

    processed
  end

  # UI-fiber-only: one scheduler pulse that drains queued work, advances ticks,
  # and runs LVGL timers.
  #
  # Returns a clamped delay in milliseconds suitable for sleeping before the
  # next call.
  def step : UInt32
    drain_scheduled_work
    tick_inc

    wait_ms = timer_handler
    wait_ms > @max_sleep_ms ? @max_sleep_ms : wait_ms
  end

  # Close the scheduler queue and reject new scheduled work.
  def close : Nil
    return if closed?

    @closed.set(CLOSED_FLAG)
    @queue.close
  end

  # Returns whether this scheduler has been closed.
  def closed? : Bool
    @closed.get == CLOSED_FLAG
  end
end
