require "signal"
require "./lvgl/raw"
require "./lvgl/runtime"
require "./lvgl/backend"
require "./lvgl/object"
require "./lvgl/event"
require "./lvgl/widgets/label"
require "./lvgl/widgets/button"

# Crystal bindings and runtime helpers for LVGL examples.
module Lvgl::Crystal
  VERSION = "0.1.0"

  # TODO: This should be initialized at the right time per Lvgl::Scheduler
  @@screen = Lvgl::Object.active_screen
  @@setup_blocks = Array(Proc(Lvgl::Object, Nil))
  @@loop_blocks = Array(Proc(Lvgl::Object, Message, Nil))
  @@cleanup_blocks = Array(Proc(Lvgl::Object, Nil))

  def self.setup(&block : Lvgl::Object ->)
    # TODO: This method should tie all callers to setup into something that runs
    # the blocks at the appropriate time for to-be-done Lvgl::Scheduler.
    #
    # This should perform the initial setup for the application or applet. It is
    # possible that multiple applets could be run for things like web pages. Or
    # applets could be started up and closed down by a launcher application.
    @@setup_blocks << block
  end

  def self.loop(&block : Lvgl::Object ->)
    # TODO: This method should tie all callers to setup into something that runs
    # the blocks at the appropriate time for to-be-done Lvgl::Scheduler.
    #
    # This should perform the main UI for the application or applet. It should
    # be reasonable for event handlers to communicate with code in this loop, but
    # it should not be required to entirely change the pattern to force the code
    # to be moved to this block. What might make sense is to run the event handlers
    # and the blocks provided via this method on the same Fiber and perhaps even
    # the same `select`.
    @@loop_blocks << block
  end

  def self.cleanup(&block : Lvgl::Object ->)
    # TODO: This method should tie all callers to setup into something that runs
    # the blocks at the appropriate time for to-be-done Lvgl::Scheduler
    @@cleanup_blocks << block
  end

  # TODO: Whatever structure our system tick timer message should be
  # to tell us what to do should replace this. I'm not sure where it
  # should be defined, because it isn't just Lvgl::Event, so maybe it
  # should be defined here. I'd expect Lvgl::Scheduler can also generate
  # these messages, perhaps based on the tick in Lvgl::Runtime?
  struct Message
    dummy : String
  end

  @@messages = Channel(Message).new(1)

  # TODO: Put these fibers on the right place using Lvgl::Scheduler.
  # TODO: Wire this all into an Lvgl::Backend.
  #
  # Below is just a hack that should be cleaned up using Lvgl::Scheduler and
  # Lvgl::Backend.
  def self.main(&)
    sigs = Channel(Signal).new(1)
    Signal::INT.trap do
      sigs.send(Signal::INT)
    end
    spawn name: "Lvgl::Crystal.main" do
      @@setup_blocks.each do |block|
        yield
        block(@@screen)
      end

      loop do
        yield
        select
        when signal = sigs.receive
          puts "Got SIGINT, terminating..."
          break
        when message = @@messages.receive
          @@loop_blocks.each do |block, message|
            block(@@screen, message)
          end
        end
      end

      @@cleanup_blocks.each do |block|
        block(@@screen)
      end
    end
  end

  # TODO: replace this with something tied into Lvgl::Scheduler, Lvgl::Runtime or whereever it really goes
  def self.temp_message_generator(&)
    spawn name: "Lvgl::Crystal.temp_message_generator" do
      loop do
        yield
        sleep(1.millisecond)
        @@messages.send(Message.new("dummy"))
      end
    end
  end
end

Lvgl::Crystal.temp_message_generator # TODO: remove

Lvgl::Crystal.main
