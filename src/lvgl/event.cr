require "box"
require "mutex"

require "./raw"
require "./object"

# Channel-oriented LVGL event bridge.
#
# This first pass intentionally keeps callback behavior fixed and predictable:
# event callbacks only publish typed messages onto a `Channel`.
#
# Crystal callers subscribe through `Lvgl::Object#on_event` (or `Lvgl::Event.on`)
# and consume messages from the returned subscription channel.
#
# ## Lifecycle contract
#
# - Keep the returned `Subscription` alive while receiving events.
# - Call `subscription.release` when done to:
#   - remove the LVGL event descriptor;
#   - close the channel;
#   - remove Crystal-side retention for callback state.
# - If you skip `release`, the callback state remains retained for process lifetime.
#
# ## Expansion path
#
# Future iterations can add more event codes, typed payload extraction, and
# higher-level stream combinators.
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
    getter code_raw : Int32
    getter target_raw : Pointer(LibLvgl::LvObjT)
    getter current_target_raw : Pointer(LibLvgl::LvObjT)

    def initialize(@code_raw : Int32, @target_raw : Pointer(LibLvgl::LvObjT), @current_target_raw : Pointer(LibLvgl::LvObjT))
    end

    # Returns wrapped enum value when present in the current subset.
    def code? : Code?
      Code.from_value?(@code_raw)
    end
  end

  private class Handler
    getter channel : Channel(Message)

    def initialize(@channel : Channel(Message))
    end
  end

  # Handle returned from `Event.on`/`Object#on_event`.
  class Subscription
    @object : Lvgl::Object
    @descriptor : Pointer(LibLvgl::LvEventDscT)
    @user_data : Void*
    @released = false

    getter channel : Channel(Message)

    protected getter object : Lvgl::Object
    protected getter descriptor : Pointer(LibLvgl::LvEventDscT)
    protected getter user_data : Void*

    protected def initialize(@object : Lvgl::Object, @descriptor : Pointer(LibLvgl::LvEventDscT), @user_data : Void*, @channel : Channel(Message))
    end

    def released? : Bool
      @released
    end

    # Remove callback and close channel. Idempotent.
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

  protected def self.unregister(subscription : Subscription) : Bool
    removed = LibLvgl.lv_obj_remove_event_dsc(subscription.object.to_unsafe, subscription.descriptor)
    return false unless removed

    release_handler(subscription.user_data).try &.channel.close
    true
  end

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
    handler.channel.try_send(message)
  end

  private def self.release_handler(user_data : Void*) : Handler?
    @@registry_mutex.synchronize do
      @@handler_registry.delete(pointer_key(user_data))
    end
  end

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
end
