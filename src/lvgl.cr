require "signal"
require "log"
require "time"
require "./lvgl/raw"
require "./lvgl/types"
require "./lvgl/runtime"
require "./lvgl/scheduler"
require "./lvgl/backend"
require "./lvgl/object"
require "./lvgl/event"
require "./lvgl/widgets/label"
require "./lvgl/widgets/button"

# Crystal bindings, runtime helpers, and applet entry pattern for LVGL examples.
#
# ## Applet usage pattern
#
# 1. Create a class inheriting `Lvgl::Applet`.
# 2. Build your UI in `#setup(screen)`.
# 3. Handle periodic work in `#loop(screen, message)`.
# 4. Optionally release resources in `#cleanup(screen)`.
#
# Example:
# ```
# class HelloApplet < Lvgl::Applet
#   def setup(screen)
#     label = Lvgl::Label.new(screen)
#     label.set_text("Hello world")
#     label.center
#   end
# end
# ```
module Lvgl
  VERSION = "0.1.0"

  # Base class for beginner-friendly app entry points.
  #
  # Subclasses override `setup`, `loop`, and optionally `cleanup`.
  class Applet
    @@registry = [] of Applet.class

    # Automatically register each concrete applet subclass when loaded.
    def self.inherited(subclass)
      @@registry << subclass
    end

    # Returns all discovered applet subclasses.
    def self.registry : Array(Applet.class)
      @@registry
    end

    # One-time applet initialization hook.
    def setup(screen : Lvgl::Object = Lvgl::Object.screen_active)
    end

    # Repeated frame/tick hook called by the runtime loop.
    def loop(screen : Lvgl::Object = Lvgl::Object.screen_active, message : Lvgl::Message = Lvgl::Message.new)
    end

    # Finalization hook called during orderly shutdown.
    def cleanup(screen : Lvgl::Object = Lvgl::Object.screen_active)
    end
  end

  alias Button = Widgets::Button
  alias Label = Widgets::Label

  # Runtime loop message passed to `Applet#loop`.
  struct Message
    getter tick_ms : UInt64

    # Builds a loop message containing elapsed runtime tick count.
    def initialize(@tick_ms : UInt64 = 0_u64)
    end
  end

  # Runs all registered applets using the selected backend and scheduler.
  def self.main : Int32
    backend = Backend.from_env
    raise backend.unavailable_reason || "LVGL backend unavailable" unless backend.available?

    # TODO: Add busybox-style symlink dispatch so one executable can select and run
    # a single applet by invocation name.
    applets = Applet.registry.map(&.new)
    return 0 if applets.empty?

    backend.setup!
    begin
      screen = Lvgl::Object.screen_active
      applets.each(&.setup(screen))

      scheduler = Runtime.scheduler
      interrupted = false
      sigs = Channel(Nil).new(1)
      Signal::INT.trap { sigs.send(nil) }
      tick_ms = 0_u64

      until interrupted
        select
        when sigs.receive
          interrupted = true
        when timeout(1.millisecond)
          scheduler.tick_inc(1)
          tick_ms += 1

          wait_ms = scheduler.timer_handler
          scheduler.drain_scheduled_work
          message = Lvgl::Message.new(tick_ms)
          applets.each { |applet| applet.loop(screen, message) }

          sleep(wait_ms > 0 ? wait_ms.milliseconds : 1.millisecond)
        end
      end

      applets.each(&.cleanup(screen))
    ensure
      backend.teardown!
      Runtime.shutdown
    end

    0
  end
end

# Configure logging from environment variables (if set).
Log.setup_from_env

# Run applets automatically when this file is used as an executable entry point.
at_exit do
  next if Lvgl::Applet.registry.empty?
  next if PROGRAM_NAME.downcase.includes?("spec")

  Lvgl.main
end
