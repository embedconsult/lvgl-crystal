require "signal"
require "log"
require "time"
require "./lvgl/raw"
require "./lvgl/types"
require "./lvgl/runtime"
require "./lvgl/scheduler"
require "./lvgl/backend"
require "./lvgl/style"
require "./lvgl/object"
require "./lvgl/event"
require "./lvgl/snapshot"
require "./lvgl/widgets/label"
require "./lvgl/widgets/button"
require "./lvgl/widgets/slider"

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
  APPLETS = {{ Applet.all_subclasses }}

  # Compile-time metadata annotation for LVGL example applet classes.
  #
  # Required named arguments:
  # - `section` (String): High-level docs grouping (e.g., "Get Started").
  # - `title` (String): Human-readable example title shown in docs index.
  # - `image_path` (String): Relative docs path (e.g., "images/example.png").
  # - `source_url` (String): Canonical LVGL upstream example URL under
  #   https://docs.lvgl.io/9.4/examples.html.
  annotation ExampleMetadata
  end

  # Base class for beginner-friendly app entry points.
  #
  # Subclasses override `setup`, `loop`, and optionally `cleanup`.
  class Applet
    macro inherited
      # Allow `Lvgl::Applet` runners to know the base filename for the subclass.
      def source_basename
        Path[__FILE__].stem
      end

      # Allow `Lvgl::Applet` runners to know the class name for the subclass.
      #
      # {{ @type.name.stringify }}
      def class_name
        {{ @type.name.stringify }}
      end
    end

    # Allow `Applet` runners to know the base filename for the subclass.
    def source_basename
      Path[__FILE__].stem
    end

    # Allow `Applet` runners to know the class name for the subclass.
    def class_name
      {{ @type.name.stringify }}
    end

    # Returns all applet subclasses using compile-time macro.
    def self.registry : Array(Applet.class)
      APPLETS.compact_map do |subclass|
        subclass.as?(Applet.class)
      end
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
    max_ticks = ENV["LVGL_APPLET_MAX_TICKS"]?.try(&.to_u64?)

    applets = Applet.registry.map(&.new)
    return 0 if applets.empty?

    backend.setup!
    begin
      screen = Lvgl::Object.screen_active
      applets.each do |applet|
        Log.debug { "Calling #{applet.class_name} (#{applet.source_basename}) `setup` method" }
        applet.setup(screen)
      end

      scheduler = Runtime.scheduler
      interrupted = false
      sigs = Channel(Nil).new(1)
      Signal::INT.trap { sigs.send(nil) }
      tick_ms = 0_u64

      Log.debug { "Entering main `loop`" }
      until interrupted
        if max_ticks && tick_ms >= max_ticks
          interrupted = true
          next
        end

        select
        when sigs.receive
          interrupted = true
        when timeout(1.millisecond)
          scheduler.tick_inc(1)
          tick_ms += 1

          wait_ms = Runtime.timer_handler
          scheduler.drain_scheduled_work
          message = Lvgl::Message.new(tick_ms)
          applets.each(&.loop(screen, message))

          sleep(wait_ms > 0 ? wait_ms.milliseconds : 1.millisecond)
        end
      end

      applets.each do |applet|
        Log.debug { "Calling #{applet.class_name} (#{applet.source_basename}) `cleanup` method" }
        applet.setup(screen)
      end
    ensure
      backend.teardown!
      Runtime.shutdown
    end

    0
  end
end

# Configure logging from environment variables (if set).
Log.setup_from_env
Log.debug { "Applets found: #{Lvgl::Applet.registry}" }

# Run applets automatically when this file is used as an executable entry point.
at_exit do
  next if Lvgl::Applet.registry.empty?
  next if PROGRAM_NAME.downcase.includes?("spec")
  next if ENV["LVGL_NO_AUTORUN"]? == "1"

  Lvgl.main
end
