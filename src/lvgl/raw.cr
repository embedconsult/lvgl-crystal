@[Link("lvgl", ldflags: "-L#{__DIR__}/../../lib/lvgl/build/crystal -Wl,-rpath,#{__DIR__}/../../lib/lvgl/build/crystal")]
lib LibLvgl
  # Opaque LVGL base object type from
  # [`lv_obj.h`](lib/lvgl/src/core/lv_obj.h).
  type LvObjT = Void

  # Opaque LVGL event descriptor type from
  # [`lv_event.h`](lib/lvgl/src/misc/lv_event.h).
  type LvEventT = Void

  # Opaque LVGL event-callback descriptor type from
  # [`lv_obj_event.h`](lib/lvgl/src/core/lv_obj_event.h).
  type LvEventDscT = Void

  # Opaque LVGL display handle from
  # [`lv_display.h`](lib/lvgl/src/display/lv_display.h).
  type LvDisplayT = Void

  # LVGL coordinate type (`lv_coord_t`) used for object geometry.
  #
  # Coordinates are interpreted in LVGL's object-local coordinate system and are
  # typically pixel units unless helper macros such as `lv_pct(...)` are used.
  # See [`lv_obj_pos.h`](lib/lvgl/src/core/lv_obj_pos.h).
  alias LvCoordT = Int32

  # LVGL alignment selector (`lv_align_t`) used by positioning helpers.
  # See [`lv_obj_pos.h`](lib/lvgl/src/core/lv_obj_pos.h).
  alias LvAlignT = Int32

  # LVGL event code enum (`lv_event_code_t`) used for filtering and dispatch.
  # See [`lv_event.h`](lib/lvgl/src/misc/lv_event.h).
  alias LvEventCodeT = Int32
  alias LvPartT = UInt32
  alias LvStyleSelectorT = UInt32

  struct LvColorT
    blue : UInt8
    green : UInt8
    red : UInt8
  end

  # LVGL event callback signature (`lv_event_cb_t`).
  # See [`lv_event.h`](lib/lvgl/src/misc/lv_event.h).
  alias LvEventCbT = Pointer(LvEventT) ->

  # C declaration provenance: `lib/lvgl/src/lv_init.h` (`lv_init`, `lv_deinit`) and
  # `lib/lvgl/src/tick/lv_tick.h` + `lib/lvgl/src/misc/lv_timer.h`
  # (`lv_tick_inc`, `lv_timer_handler`).

  # Initialize the global LVGL runtime state.
  # Crystal caller: `Lvgl::Runtime`.
  fun lv_init : Void

  # Advance LVGL's monotonic tick source by `tick_period` milliseconds.
  # Crystal caller: `Lvgl::Scheduler`.
  fun lv_tick_inc(tick_period : UInt32) : Void

  # Run due LVGL timers and return milliseconds until the next recommended call.
  # Crystal caller: `Lvgl::Scheduler`.
  fun lv_timer_handler : UInt32

  # Tear down LVGL global state.
  #
  # This symbol is present in LVGL 9.4's shared object build distributed with this
  # repository (`lib/lvgl/build/crystal/liblvgl.so`).
  # Crystal caller: `Lvgl::Runtime`.
  fun lv_deinit : Void

  # Returns the active screen object for the default display.
  #
  # Reference: [`lv_display.h`](lib/lvgl/src/display/lv_display.h).
  # Crystal caller: `Lvgl::Object`.
  fun lv_screen_active : Pointer(LvObjT)

  # Legacy v8 API name kept in LVGL's API map.
  #
  # Reference mapping: [`lv_api_map_v8.h`](lib/lvgl/src/lv_api_map_v8.h).
  # Crystal caller: TODO.
  fun lv_scr_act = lv_screen_active : Pointer(LvObjT)

  # Create a base object.
  #
  # `parent` is the parent object. If `NULL`, LVGL creates a new screen object.
  # Reference: [`lv_obj.h`](lib/lvgl/src/core/lv_obj.h).
  # Crystal caller: `Lvgl::Object`.
  fun lv_obj_create(parent : Pointer(LvObjT)) : Pointer(LvObjT)

  # Create a label widget object.
  #
  # `parent` is the parent object. If `NULL`, LVGL creates a new screen object.
  # Reference: [`lv_label.h`](lib/lvgl/src/widgets/label/lv_label.h).
  # Crystal caller: `Lvgl::Widgets::Label`.
  fun lv_label_create(parent : Pointer(LvObjT)) : Pointer(LvObjT)

  # Set label text from a UTF-8 C string.
  #
  # LVGL copies the bytes into an internal, dynamically allocated buffer.
  # Reference: [`lv_label.h`](lib/lvgl/src/widgets/label/lv_label.h).
  # Crystal caller: `Lvgl::Widgets::Label`.
  fun lv_label_set_text(obj : Pointer(LvObjT), text : UInt8*) : Void

  # Create a button widget object.
  #
  # Symbol name follows LVGL 9 exports (`lv_button_create`) from
  # `lib/lvgl/build/crystal/liblvgl.so`.
  # Reference: [`lv_button.h`](lib/lvgl/src/widgets/button/lv_button.h).
  # Crystal caller: `Lvgl::Widgets::Button`.
  fun lv_button_create(parent : Pointer(LvObjT)) : Pointer(LvObjT)

  # Set object width and height in LVGL coordinate units.
  #
  # `w` and `h` are `lv_coord_t` values interpreted by LVGL layout/size rules.
  # Reference: [`lv_obj_pos.h`](lib/lvgl/src/core/lv_obj_pos.h).
  # Crystal caller: `Lvgl::Object`.
  fun lv_obj_set_size(obj : Pointer(LvObjT), w : LvCoordT, h : LvCoordT) : Void

  # Set object position in parent content coordinates.
  #
  # `x` and `y` are `lv_coord_t` values.
  # Reference: [`lv_obj_pos.h`](lib/lvgl/src/core/lv_obj_pos.h).
  # Crystal caller: `Lvgl::Object`.
  fun lv_obj_set_pos(obj : Pointer(LvObjT), x : LvCoordT, y : LvCoordT) : Void

  # Align object to the center of its parent.
  #
  # Reference: [`lv_obj_pos.h`](lib/lvgl/src/core/lv_obj_pos.h).
  # Crystal caller: `Lvgl::Object`.
  fun lv_obj_center(obj : Pointer(LvObjT)) : Void

  # Align object to a position inside its parent with optional x/y offsets.
  #
  # `align` is an `lv_align_t` value, and `x_ofs` / `y_ofs` are coordinate offsets
  # from the selected anchor.
  # Reference: [`lv_obj_pos.h`](lib/lvgl/src/core/lv_obj_pos.h).
  # Crystal caller: TODO.
  fun lv_obj_align(obj : Pointer(LvObjT), align : LvAlignT, x_ofs : LvCoordT, y_ofs : LvCoordT) : Void

  # Align object relative to another base object.
  #
  # `base` is the reference object used for anchor calculation.
  # Reference: [`lv_obj_pos.h`](lib/lvgl/src/core/lv_obj_pos.h).
  # Crystal caller: TODO.
  fun lv_obj_align_to(obj : Pointer(LvObjT), base : Pointer(LvObjT), align : LvAlignT, x_ofs : LvCoordT, y_ofs : LvCoordT) : Void

  # Return the child object at `idx` from the object's tree children.
  #
  # Reference: [`lv_obj_tree.h`](lib/lvgl/src/core/lv_obj_tree.h).
  # Crystal caller: `Lvgl::Object#[]`.
  fun lv_obj_get_child(obj : Pointer(LvObjT), idx : Int32) : Pointer(LvObjT)

  # Convert a 24-bit RGB hex value into LVGL's native `lv_color_t`.
  #
  # Reference: [`lv_color.h`](lib/lvgl/src/misc/lv_color.h).
  # Crystal caller: `Lvgl::Color.hex`.
  fun lv_color_hex(c : UInt32) : LvColorT

  # Set object background color for the given style selector.
  #
  # Reference: [`lv_obj_style_gen.h`](lib/lvgl/src/core/lv_obj_style_gen.h).
  # Crystal caller: `Lvgl::Object#set_style_bg_color`.
  fun lv_obj_set_style_bg_color(obj : Pointer(LvObjT), value : LvColorT, selector : LvStyleSelectorT) : Void

  # Set object text color for the given style selector.
  #
  # Reference: [`lv_obj_style_gen.h`](lib/lvgl/src/core/lv_obj_style_gen.h).
  # Crystal caller: `Lvgl::Object#set_style_text_color`.
  fun lv_obj_set_style_text_color(obj : Pointer(LvObjT), value : LvColorT, selector : LvStyleSelectorT) : Void

  # Register an event callback on an object.
  #
  # `filter` can be one specific `lv_event_code_t` or `LV_EVENT_ALL`.
  # Returns a descriptor that can later be removed with `lv_obj_remove_event_dsc`.
  # Reference: [`lv_obj_event.h`](lib/lvgl/src/core/lv_obj_event.h).
  # Crystal caller: `Lvgl::Event`.
  fun lv_obj_add_event_cb(obj : Pointer(LvObjT), event_cb : LvEventCbT, filter : LvEventCodeT, user_data : Void*) : Pointer(LvEventDscT)

  # Remove one previously registered event descriptor.
  #
  # Returns `true` if the descriptor was found and removed.
  # Reference: [`lv_obj_event.h`](lib/lvgl/src/core/lv_obj_event.h).
  # Crystal caller: `Lvgl::Event`.
  fun lv_obj_remove_event_dsc(obj : Pointer(LvObjT), dsc : Pointer(LvEventDscT)) : Bool

  # Return the event code for an incoming event descriptor.
  #
  # Reference: [`lv_event.h`](lib/lvgl/src/misc/lv_event.h).
  # Crystal caller: `Lvgl::Event` message mapping.
  fun lv_event_get_code(e : Pointer(LvEventT)) : LvEventCodeT

  # Return the original target object for an incoming event descriptor.
  #
  # Reference: [`lv_event.h`](lib/lvgl/src/misc/lv_event.h).
  # Crystal caller: `Lvgl::Event` message mapping.
  fun lv_event_get_target(e : Pointer(LvEventT)) : Pointer(LvObjT)

  # Return the current target object (while bubbling/trickling) for an event.
  #
  # Reference: [`lv_event.h`](lib/lvgl/src/misc/lv_event.h).
  # Crystal caller: `Lvgl::Event` message mapping.
  fun lv_event_get_current_target(e : Pointer(LvEventT)) : Pointer(LvObjT)

  # Return the registration `user_data` pointer attached to this callback.
  #
  # Reference: [`lv_event.h`](lib/lvgl/src/misc/lv_event.h).
  # Crystal caller: `Lvgl::Event` callback trampoline.
  fun lv_event_get_user_data(e : Pointer(LvEventT)) : Void*

  # Create a dummy display for LVGL tests.
  #
  # Reference: `lib/lvgl/src/others/test/lv_test_display.h`
  fun lv_test_display_create(hor_res : Int32, ver_res : Int32) : Pointer(LvDisplayT)

  # Create all test input devices (mouse/keypad/encoder).
  #
  # Reference: `lib/lvgl/src/others/test/lv_test_indev.h`
  fun lv_test_indev_create_all : Void

  # Delete all test input devices created by `lv_test_indev_create_all`.
  #
  # Reference: `lib/lvgl/src/others/test/lv_test_indev.h`
  fun lv_test_indev_delete_all : Void
end
