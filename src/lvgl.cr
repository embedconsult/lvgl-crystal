require "signal"
require "log"
require "time"
require "./lvgl/raw"
require "./lvgl/runtime"
require "./lvgl/scheduler"
require "./lvgl/backend"
require "./lvgl/object"
require "./lvgl/event"
require "./lvgl/widgets/label"
require "./lvgl/widgets/button"

# Crystal bindings and runtime helpers for LVGL examples.
module Lvgl
  VERSION = "0.1.0"

  # TODO: These should be initialized at the right time per Lvgl::Scheduler
  @@screen = Lvgl::Object.screen_active
  @@applets : Array(Applet) = [] of Applet

  # TODO: Whatever structure our system tick timer message should be
  # to tell us what to do should replace this. I'm not sure where it
  # should be defined, because it isn't just Lvgl::Event, so maybe it
  # should be defined here. I'd expect Lvgl::Scheduler can also generate
  # these messages, perhaps based on the tick in Lvgl::Runtime?
  struct Message
    dummy : String
  end

  @@messages = Channel(Message).new(1)

  class Applet
    def definitions
      @@definitions
    end

    # TODO: This method should tie all callers to setup into something that runs
    # the blocks at the appropriate time for to-be-done Lvgl::Scheduler.
    #
    # This should perform the initial setup for the application or applet. It is
    # possible that multiple applets could be run for things like web pages. Or
    # applets could be started up and closed down by a launcher application.
    def setup(screen : Lvgl::Object = Lvgl::Object.screen_active)
    end

    # TODO: This method should tie all callers to setup into something that runs
    # the blocks at the appropriate time for to-be-done Lvgl::Scheduler.
    #
    # This should perform the main UI for the application or applet. It should
    # be reasonable for event handlers to communicate with code in this loop, but
    # it should not be required to entirely change the pattern to force the code
    # to be moved to this block. What might make sense is to run the event handlers
    # and the blocks provided via this method on the same Fiber and perhaps even
    # the same `select`.
    def loop(screen : Lvgl::Object = Lvgl::Object.screen_active, message : Lvgl::Message = Lvgl::Message.new)
    end

    # TODO: This method should tie all callers to setup into something that runs
    # the blocks at the appropriate time for to-be-done Lvgl::Scheduler
    def cleanup(screen : Lvgl::Object = Lvgl::Object.screen_active)
    end
  end

  APPLETS = {{ Applet.subclasses }}

  # TODO: Put these fibers on the right place using Lvgl::Scheduler.
  # TODO: Wire this all into an Lvgl::Backend.
  #
  # Below is just a hack that should be cleaned up using Lvgl::Scheduler and
  # Lvgl::Backend.
  def self.main : Int32
    scheduler = Runtime.scheduler
    sigs = Channel(Signal).new(1)
    Signal::INT.trap do
      sigs.send(Signal::INT)
    end

    # For now, instantiate one of every applet
    # TODO: add "busybox-style" symlink invocation
    APPLETS.each do |applet_class|
      @@applets << applet_class.new
    end

    spawn name: "Lvgl.main" do
      # Call each `setup`
      @@applets.each do |applet|
        Fiber.yield
        applet.setup(@@screen)
      end

      # Call each `loop` on every timer_handler event until terminated
      #
      # TODO: understand if timer tick and UI should be on the same fiber
      loop do
        Fiber.yield
        select
        when timeout(1.millisecond)
          scheduler.tick_inc(1)
        when wait = scheduler.timer_handler
          sleep(wait.milliseconds)
          scheduler.drain_scheduled_work
          @@applets.each do |applet|
            applet.loop(@@screen, message)
          end
        when signal = sigs.receive
          puts "Got SIGINT, terminating..."
          break
        end
      end

      # Call each `cleanup`
      @@applets.each do |applet|
        Fiber.yield
        applet.cleanup(@@screen)
      end
    end
    Runtime.shutdown
    0
  end
end

Log.setup_from_env
Log.debug { "Running #{Lvgl::APPLETS.size} applets" }
exit 0 if Lvgl::APPLETS.empty?
Lvgl.main
