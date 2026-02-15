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

  # Opaque LVGL draw buffer type used by snapshot APIs.
  # [`lv_draw_buf.h`](lib/lvgl/src/draw/lv_draw_buf.h).
  type LvDrawBufT = Void
  type LvAnimT = Void
  type LvStyleTransitionDscT = Void

  # LVGL mutable style descriptor (`lv_style_t`).
  #
  # Layout reference: [`lv_style.h`](lib/lvgl/src/misc/lv_style.h).
  struct LvStyleT
    values_and_props : Void*
    has_group : UInt32
    prop_cnt : UInt8
  end

  # LVGL color filter descriptor (`lv_color_filter_dsc_t`).
  #
  # Layout reference: [`lv_color_op.h`](lib/lvgl/src/misc/lv_color_op.h).
  struct LvColorFilterDscT
    filter_cb : Void*
    user_data : Void*
  end

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
  alias LvStateT = UInt32
  alias LvStylePropT = UInt8

  # LVGL style selector type (`lv_style_selector_t`), a combined bitmask of
  # `lv_part_t` and `lv_state_t`.
  alias LvStyleSelectorT = UInt32

  # Raw LVGL color struct (`lv_color_t`).
  struct LvColorT
    blue : UInt8
    green : UInt8
    red : UInt8
  end

  # LVGL style value union (`lv_style_value_t`).
  union LvStyleValueT
    num : Int32
    ptr : Void*
    color : LvColorT
  end

  # LVGL event callback signature (`lv_event_cb_t`).
  # See [`lv_event.h`](lib/lvgl/src/misc/lv_event.h).
  alias LvEventCbT = Pointer(LvEventT) ->

  # LVGL color filter callback signature (`lv_color_filter_cb_t`).
  # See [`lv_color_op.h`](lib/lvgl/src/misc/lv_color_op.h).
  alias LvColorFilterCbT = Pointer(LvColorFilterDscT), LvColorT, UInt8 -> LvColorT

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

  # Returns the default display handle.
  #
  # Reference: [`lv_display.h`](lib/lvgl/src/display/lv_display.h).
  fun lv_display_get_default : Pointer(LvDisplayT)

  # Returns the active draw buffer for a display.
  #
  # Reference: [`lv_display.h`](lib/lvgl/src/display/lv_display.h).
  fun lv_display_get_buf_active(disp : Pointer(LvDisplayT)) : Pointer(LvDrawBufT)

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

  # Create a slider widget object.
  #
  # Symbol name follows LVGL 9 exports (`lv_slider_create`).
  # Crystal caller: `Lvgl::Widgets::Slider`.
  fun lv_slider_create(parent : Pointer(LvObjT)) : Pointer(LvObjT)

  # Return the current integer value from a slider widget.
  #
  # Crystal caller: `Lvgl::Widgets::Slider#value`.
  fun lv_slider_get_value(obj : Pointer(LvObjT)) : Int32

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

  # Return the main color of a built-in palette.
  fun lv_palette_main(palette : Int32) : LvColorT

  # Return a lightened color variant from a built-in palette.
  fun lv_palette_lighten(palette : Int32, level : UInt8) : LvColorT

  # Return a darkened color variant from a built-in palette.
  fun lv_palette_darken(palette : Int32, level : UInt8) : LvColorT

  # Darken any color by an opacity amount.
  fun lv_color_darken(color : LvColorT, level : UInt8) : LvColorT

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

  # Remove all styles currently attached to an object.
  #
  # Crystal caller: `Lvgl::Object#remove_style_all`.
  fun lv_obj_remove_style_all(obj : Pointer(LvObjT)) : Void

  # Set the background opacity style value.
  fun lv_obj_set_style_bg_opa(obj : Pointer(LvObjT), value : UInt8, selector : LvStyleSelectorT) : Void

  # Set the background gradient secondary color style value.
  fun lv_obj_set_style_bg_grad_color(obj : Pointer(LvObjT), value : LvColorT, selector : LvStyleSelectorT) : Void

  # Set the background gradient direction style value.
  fun lv_obj_set_style_bg_grad_dir(obj : Pointer(LvObjT), value : Int32, selector : LvStyleSelectorT) : Void

  # Set the border color style value.
  fun lv_obj_set_style_border_color(obj : Pointer(LvObjT), value : LvColorT, selector : LvStyleSelectorT) : Void

  # Set the border opacity style value.
  fun lv_obj_set_style_border_opa(obj : Pointer(LvObjT), value : UInt8, selector : LvStyleSelectorT) : Void

  # Set the border width style value.
  fun lv_obj_set_style_border_width(obj : Pointer(LvObjT), value : Int32, selector : LvStyleSelectorT) : Void

  # Set the corner radius style value.
  fun lv_obj_set_style_radius(obj : Pointer(LvObjT), value : Int32, selector : LvStyleSelectorT) : Void

  # Add a style descriptor to an object for one selector.
  fun lv_obj_add_style(obj : Pointer(LvObjT), style : Pointer(LvStyleT), selector : LvStyleSelectorT) : Void

  # Add one or more states to an object.
  fun lv_obj_add_state(obj : Pointer(LvObjT), state : LvStateT) : Void

  # Remove one or more states from an object.
  fun lv_obj_remove_state(obj : Pointer(LvObjT), state : LvStateT) : Void

  # Initialize a mutable style descriptor.
  fun lv_style_init(style : Pointer(LvStyleT)) : Void

  # Clear style properties and free dynamic style memory.
  fun lv_style_reset(style : Pointer(LvStyleT)) : Void

  # Set style background color.
  fun lv_style_set_bg_color(style : Pointer(LvStyleT), value : LvColorT) : Void

  # Set style background opacity.
  fun lv_style_set_bg_opa(style : Pointer(LvStyleT), value : UInt8) : Void

  # Set style background gradient secondary color.
  fun lv_style_set_bg_grad_color(style : Pointer(LvStyleT), value : LvColorT) : Void

  # Set style background gradient direction.
  fun lv_style_set_bg_grad_dir(style : Pointer(LvStyleT), value : Int32) : Void

  # Set style background gradient start stop.
  fun lv_style_set_bg_main_stop(style : Pointer(LvStyleT), value : Int32) : Void

  # Set style background gradient end stop.
  fun lv_style_set_bg_grad_stop(style : Pointer(LvStyleT), value : Int32) : Void

  # Set style background main opacity.
  fun lv_style_set_bg_main_opa(style : Pointer(LvStyleT), value : UInt8) : Void

  # Set style background gradient opacity.
  fun lv_style_set_bg_grad_opa(style : Pointer(LvStyleT), value : UInt8) : Void

  # Set style background image source.
  fun lv_style_set_bg_image_src(style : Pointer(LvStyleT), value : Void*) : Void

  # Set style background image opacity.
  fun lv_style_set_bg_image_opa(style : Pointer(LvStyleT), value : UInt8) : Void

  # Set style background image recolor.
  fun lv_style_set_bg_image_recolor(style : Pointer(LvStyleT), value : LvColorT) : Void

  # Set style background image recolor opacity.
  fun lv_style_set_bg_image_recolor_opa(style : Pointer(LvStyleT), value : UInt8) : Void

  # Set style background image tiled flag.
  fun lv_style_set_bg_image_tiled(style : Pointer(LvStyleT), value : Bool) : Void

  # Set style border color.
  fun lv_style_set_border_color(style : Pointer(LvStyleT), value : LvColorT) : Void

  # Set style border opacity.
  fun lv_style_set_border_opa(style : Pointer(LvStyleT), value : UInt8) : Void

  # Set style border width.
  fun lv_style_set_border_width(style : Pointer(LvStyleT), value : Int32) : Void

  # Set style border sides mask.
  fun lv_style_set_border_side(style : Pointer(LvStyleT), value : Int32) : Void

  # Set style border post-render flag.
  fun lv_style_set_border_post(style : Pointer(LvStyleT), value : Bool) : Void

  # Set style outline width.
  fun lv_style_set_outline_width(style : Pointer(LvStyleT), value : Int32) : Void

  # Set style outline color.
  fun lv_style_set_outline_color(style : Pointer(LvStyleT), value : LvColorT) : Void

  # Set style outline opacity.
  fun lv_style_set_outline_opa(style : Pointer(LvStyleT), value : UInt8) : Void

  # Set style outline pad.
  fun lv_style_set_outline_pad(style : Pointer(LvStyleT), value : Int32) : Void

  # Set style shadow width.
  fun lv_style_set_shadow_width(style : Pointer(LvStyleT), value : Int32) : Void

  # Set style shadow x offset.
  fun lv_style_set_shadow_offset_x(style : Pointer(LvStyleT), value : Int32) : Void

  # Set style shadow y offset.
  fun lv_style_set_shadow_offset_y(style : Pointer(LvStyleT), value : Int32) : Void

  # Set style shadow spread.
  fun lv_style_set_shadow_spread(style : Pointer(LvStyleT), value : Int32) : Void

  # Set style shadow color.
  fun lv_style_set_shadow_color(style : Pointer(LvStyleT), value : LvColorT) : Void

  # Set style shadow opacity.
  fun lv_style_set_shadow_opa(style : Pointer(LvStyleT), value : UInt8) : Void

  # Set style line width.
  fun lv_style_set_line_width(style : Pointer(LvStyleT), value : Int32) : Void

  # Set style line dash width.
  fun lv_style_set_line_dash_width(style : Pointer(LvStyleT), value : Int32) : Void

  # Set style line dash gap.
  fun lv_style_set_line_dash_gap(style : Pointer(LvStyleT), value : Int32) : Void

  # Set style line rounded flag.
  fun lv_style_set_line_rounded(style : Pointer(LvStyleT), value : Bool) : Void

  # Set style line color.
  fun lv_style_set_line_color(style : Pointer(LvStyleT), value : LvColorT) : Void

  # Set style line opacity.
  fun lv_style_set_line_opa(style : Pointer(LvStyleT), value : UInt8) : Void

  # Set style arc width.
  fun lv_style_set_arc_width(style : Pointer(LvStyleT), value : Int32) : Void

  # Set style arc rounded flag.
  fun lv_style_set_arc_rounded(style : Pointer(LvStyleT), value : Bool) : Void

  # Set style arc color.
  fun lv_style_set_arc_color(style : Pointer(LvStyleT), value : LvColorT) : Void

  # Set style arc opacity.
  fun lv_style_set_arc_opa(style : Pointer(LvStyleT), value : UInt8) : Void

  # Set style arc image source.
  fun lv_style_set_arc_image_src(style : Pointer(LvStyleT), value : Void*) : Void

  # Set style text color.
  fun lv_style_set_text_color(style : Pointer(LvStyleT), value : LvColorT) : Void

  # Set style text opacity.
  fun lv_style_set_text_opa(style : Pointer(LvStyleT), value : UInt8) : Void

  # Set style text letter spacing.
  fun lv_style_set_text_letter_space(style : Pointer(LvStyleT), value : Int32) : Void

  # Set style text line spacing.
  fun lv_style_set_text_line_space(style : Pointer(LvStyleT), value : Int32) : Void

  # Set style text decoration flags.
  fun lv_style_set_text_decor(style : Pointer(LvStyleT), value : Int32) : Void

  # Set style text alignment.
  fun lv_style_set_text_align(style : Pointer(LvStyleT), value : Int32) : Void

  # Set text outline stroke color.
  fun lv_style_set_text_outline_stroke_color(style : Pointer(LvStyleT), value : LvColorT) : Void

  # Set text outline stroke width.
  fun lv_style_set_text_outline_stroke_width(style : Pointer(LvStyleT), value : Int32) : Void

  # Set text outline stroke opacity.
  fun lv_style_set_text_outline_stroke_opa(style : Pointer(LvStyleT), value : UInt8) : Void

  # Set style corner radius.
  fun lv_style_set_radius(style : Pointer(LvStyleT), value : Int32) : Void

  # Initialize a color filter descriptor.
  fun lv_color_filter_dsc_init(dsc : Pointer(LvColorFilterDscT), cb : LvColorFilterCbT) : Void

  # Set style color filter descriptor.
  fun lv_style_set_color_filter_dsc(style : Pointer(LvStyleT), value : Pointer(LvColorFilterDscT)) : Void

  # Set style color filter opacity.
  fun lv_style_set_color_filter_opa(style : Pointer(LvStyleT), value : UInt8) : Void

  # Set style transition descriptor.
  fun lv_style_set_transition(style : Pointer(LvStyleT), value : Pointer(LvStyleTransitionDscT)) : Void

  # Set style animation descriptor.
  fun lv_style_set_anim(style : Pointer(LvStyleT), value : Pointer(LvAnimT)) : Void

  # Set style animation duration.
  fun lv_style_set_anim_duration(style : Pointer(LvStyleT), value : UInt32) : Void

  # Set style blend mode.
  fun lv_style_set_blend_mode(style : Pointer(LvStyleT), value : Int32) : Void

  # Set style layout ID.
  fun lv_style_set_layout(style : Pointer(LvStyleT), value : UInt16) : Void

  # Set style base direction.
  fun lv_style_set_base_dir(style : Pointer(LvStyleT), value : Int32) : Void

  # Set style flex flow.
  fun lv_style_set_flex_flow(style : Pointer(LvStyleT), value : Int32) : Void

  # Set style flex main placement.
  fun lv_style_set_flex_main_place(style : Pointer(LvStyleT), value : Int32) : Void

  # Set style flex cross placement.
  fun lv_style_set_flex_cross_place(style : Pointer(LvStyleT), value : Int32) : Void

  # Set style flex track placement.
  fun lv_style_set_flex_track_place(style : Pointer(LvStyleT), value : Int32) : Void

  # Set style flex grow factor.
  fun lv_style_set_flex_grow(style : Pointer(LvStyleT), value : UInt8) : Void

  # Set style grid column descriptor array.
  fun lv_style_set_grid_column_dsc_array(style : Pointer(LvStyleT), value : Int32*) : Void

  # Set style grid column alignment.
  fun lv_style_set_grid_column_align(style : Pointer(LvStyleT), value : Int32) : Void

  # Set style grid row descriptor array.
  fun lv_style_set_grid_row_dsc_array(style : Pointer(LvStyleT), value : Int32*) : Void

  # Set style grid row alignment.
  fun lv_style_set_grid_row_align(style : Pointer(LvStyleT), value : Int32) : Void

  # Set style grid cell column position.
  fun lv_style_set_grid_cell_column_pos(style : Pointer(LvStyleT), value : Int32) : Void

  # Set style grid cell x alignment.
  fun lv_style_set_grid_cell_x_align(style : Pointer(LvStyleT), value : Int32) : Void

  # Set style grid cell column span.
  fun lv_style_set_grid_cell_column_span(style : Pointer(LvStyleT), value : Int32) : Void

  # Set style grid cell row position.
  fun lv_style_set_grid_cell_row_pos(style : Pointer(LvStyleT), value : Int32) : Void

  # Set style grid cell y alignment.
  fun lv_style_set_grid_cell_y_align(style : Pointer(LvStyleT), value : Int32) : Void

  # Set style grid cell row span.
  fun lv_style_set_grid_cell_row_span(style : Pointer(LvStyleT), value : Int32) : Void

  # Resolve one style property for an object/part with the current object state.
  fun lv_obj_get_style_prop(obj : Pointer(LvObjT), part : LvPartT, prop : LvStylePropT) : LvStyleValueT

  # Apply active color filter(s) to an already-resolved style value.
  fun lv_obj_style_apply_color_filter(obj : Pointer(LvObjT), part : LvPartT, value : LvStyleValueT) : LvStyleValueT

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

  # Snapshot an object tree into a newly allocated draw buffer.
  #
  # Reference: `lib/lvgl/src/others/snapshot/lv_snapshot.h`
  fun lv_snapshot_take(obj : Pointer(LvObjT), cf : UInt32) : Pointer(LvDrawBufT)

  # Save a draw buffer to an image file.
  #
  # Reference: `lib/lvgl/src/misc/lv_utils.h`
  fun lv_draw_buf_save_to_file(draw_buf : Pointer(LvDrawBufT), path : UInt8*) : UInt32

  # Free a draw buffer previously allocated by LVGL APIs.
  #
  # Reference: `lib/lvgl/src/draw/lv_draw_buf.h`
  fun lv_draw_buf_destroy(draw_buf : Pointer(LvDrawBufT)) : Void
end
