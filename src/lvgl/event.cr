require "box"
require "mutex"

require "./raw"
require "./object"

# Channel-oriented LVGL event bridge.
#
# ## Summary
# Registers LVGL callbacks and forwards events to typed Crystal channels.
#
# ## Notes
#
# - Keep the returned `Subscription` alive while receiving events.
# - Call `subscription.release` when done to:
#   - remove the LVGL event descriptor;
#   - close the channel;
#   - remove Crystal-side retention for callback state.
# - If you skip `release`, the callback state remains retained for process lifetime.
#
# ## Links
#
# - [LVGL events API](https://docs.lvgl.io/9.4/API/misc/lv_event_h.html)
module Lvgl::Event
  # Small initial subset of LVGL event codes for examples.
  #
  # Values must match `lv_event_code_t` from `lv_event.h`.
  enum Code : Int32
    All          =  0
    Pressed      =  1
    Pressing     =  2
    PressLost    =  3
    ShortClicked =  4
    Clicked      = 10
    Released     = 11
    ValueChanged = 35
  end

  # Event payload emitted through `Subscription#channel`.
  struct Message
    # Raw LVGL event code value.
    getter code_raw : Int32

    # Original target object pointer from LVGL.
    getter target_raw : Pointer(LibLvgl::LvObjT)

    # Current target object pointer from LVGL bubbling/trickling context.
    getter current_target_raw : Pointer(LibLvgl::LvObjT)

    # Build a message value from raw LVGL callback data.
    def initialize(@code_raw : Int32, @target_raw : Pointer(LibLvgl::LvObjT), @current_target_raw : Pointer(LibLvgl::LvObjT))
    end

    # Returns wrapped enum value when present in the current subset.
    #
    # Unknown values return `nil` so callers can stay forward-compatible.
    def code? : Code?
      Code.from_value?(@code_raw)
    end

    # Returns the original LVGL event target wrapped as `Lvgl::Object`.
    def target? : Lvgl::Object?
      Lvgl::Object.wrap(@target_raw)
    end

    # Returns the current bubbling/trickling target wrapped as `Lvgl::Object`.
    def current_target? : Lvgl::Object?
      Lvgl::Object.wrap(@current_target_raw)
    end
  end

  # Internal registry payload retained for each active LVGL callback registration.
  private class Handler
    # Channel receiving mapped event messages.
    getter channel : Channel(Message)

    # Build handler state bound to one subscription channel.
    def initialize(@channel : Channel(Message))
    end
  end

  # Handle returned from `Event.on`/`Object#on_event`.
  class Subscription
    @object : Lvgl::Object
    @descriptor : Pointer(LibLvgl::LvEventDscT)
    @user_data : Void*
    @released = false

    # Stream of event messages delivered for this registration.
    getter channel : Channel(Message)

    protected getter object : Lvgl::Object
    protected getter descriptor : Pointer(LibLvgl::LvEventDscT)
    protected getter user_data : Void*

    # Create a subscription wrapper from LVGL registration results.
    protected def initialize(@object : Lvgl::Object, @descriptor : Pointer(LibLvgl::LvEventDscT), @user_data : Void*, @channel : Channel(Message))
    end

    # Returns whether this subscription has already been released.
    def released? : Bool
      @released
    end

    # Remove callback and close channel. Idempotent.
    #
    # Returns `true` only on the first successful release.
    def release : Bool
      return false if @released

      removed = Event.unregister(self)
      @released = removed
      removed
    end
  end

  @@handler_registry = Hash(UInt64, Handler).new
  @@registry_mutex = Mutex.new

  # Register object event forwarding to a typed message channel.
  #
  # `capacity` configures channel buffering. Buffered channels avoid blocking in
  # LVGL callback context. Events are dropped if the channel buffer is full.
  #
  # Raises `ArgumentError` when `capacity` is negative.
  def self.on(object : Lvgl::Object, filter : Code = Code::All, capacity : Int32 = 32) : Subscription
    raise ArgumentError.new("capacity must be >= 0") if capacity < 0

    channel = Channel(Message).new(capacity)
    handler = Handler.new(channel)

    user_data = Box.box(handler)
    key = pointer_key(user_data)

    @@registry_mutex.synchronize do
      @@handler_registry[key] = handler
    end

    descriptor = LibLvgl.lv_obj_add_event_cb(object.to_unsafe, ->trampoline(Pointer(LibLvgl::LvEventT)), filter.to_i, user_data)
    Subscription.new(object, descriptor, user_data, channel)
  end

  # Remove one registered LVGL event descriptor and clear retained handler state.
  #
  # Returns `true` when LVGL reports successful descriptor removal.
  protected def self.unregister(subscription : Subscription) : Bool
    removed = LibLvgl.lv_obj_remove_event_dsc(subscription.object.to_unsafe, subscription.descriptor)
    return false unless removed

    release_handler(subscription.user_data).try &.channel.close
    true
  end

  # Static callback trampoline passed to LVGL.
  #
  # Looks up retained handler state by `user_data`, maps raw event fields into
  # `Message`, and non-blockingly forwards into the channel.
  private def self.trampoline(event : Pointer(LibLvgl::LvEventT)) : Nil
    user_data = LibLvgl.lv_event_get_user_data(event)
    return if user_data.null?

    handler = @@registry_mutex.synchronize do
      @@handler_registry[pointer_key(user_data)]?
    end
    return unless handler

    message = Message.new(
      code_raw: LibLvgl.lv_event_get_code(event),
      target_raw: LibLvgl.lv_event_get_target(event),
      current_target_raw: LibLvgl.lv_event_get_current_target(event)
    )

    # Avoid blocking LVGL's callback context.
    select
    when handler.channel.send(message)
    else
    end
  end

  # Drop retained handler state for `user_data` and return it when present.
  private def self.release_handler(user_data : Void*) : Handler?
    @@registry_mutex.synchronize do
      @@handler_registry.delete(pointer_key(user_data))
    end
  end

  # Convert a pointer to a stable hash key representation.
  private def self.pointer_key(pointer : Void*) : UInt64
    pointer.address.to_u64
  end
end

class Lvgl::Object
  # Subscribe to LVGL events from this object through a typed channel stream.
  #
  # See `Lvgl::Event.on` for channel buffering semantics and lifecycle details.
  def on_event(filter : Lvgl::Event::Code = Lvgl::Event::Code::All, capacity : Int32 = 32) : Lvgl::Event::Subscription
    Lvgl::Event.on(self, filter: filter, capacity: capacity)
  end

  # Block-based helper that drains the subscription channel on a spawned fiber.
  def on_event(filter : Lvgl::Event::Code = Lvgl::Event::Code::All, capacity : Int32 = 32, &block : Lvgl::Event::Message -> Nil) : Lvgl::Event::Subscription
    subscription = on_event(filter: filter, capacity: capacity)
    spawn name: "Lvgl::Object#on_event" do
      loop do
        message = subscription.channel.receive?
        break unless message

        block.call(message)
      end
    end
    subscription
  end
end
