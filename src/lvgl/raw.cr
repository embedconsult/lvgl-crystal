@[Link("lvgl", ldflags: "-L#{__DIR__}/../../lib/lvgl/build/crystal -Wl,-rpath,#{__DIR__}/../../lib/lvgl/build/crystal")]
lib LibLvgl
  # Opaque LVGL base object type from
  # [`lv_obj.h`](lib/lvgl/src/core/lv_obj.h).
  type LvObjT = Void

  # LVGL coordinate type (`lv_coord_t`) used for object geometry.
  #
  # Coordinates are interpreted in LVGL's object-local coordinate system and are
  # typically pixel units unless helper macros such as `lv_pct(...)` are used.
  # See [`lv_obj_pos.h`](lib/lvgl/src/core/lv_obj_pos.h).
  alias LvCoordT = Int32

  # LVGL alignment selector (`lv_align_t`) used by positioning helpers.
  # See [`lv_obj_pos.h`](lib/lvgl/src/core/lv_obj_pos.h).
  alias LvAlignT = Int32

  # :nodoc:
  #
  # C declaration provenance: `lib/lvgl/src/lv_init.h` (`lv_init`, `lv_deinit`) and
  # `lib/lvgl/src/tick/lv_tick.h` + `lib/lvgl/src/misc/lv_timer.h`
  # (`lv_tick_inc`, `lv_timer_handler`).

  # Initialize the global LVGL runtime state.
  fun lv_init : Void

  # Advance LVGL's monotonic tick source by `tick_period` milliseconds.
  fun lv_tick_inc(tick_period : UInt32) : Void

  # Run due LVGL timers and return milliseconds until the next recommended call.
  fun lv_timer_handler : UInt32

  # Tear down LVGL global state.
  #
  # This symbol is present in LVGL 9.4's shared object build distributed with this
  # repository (`lib/lvgl/build/crystal/liblvgl.so`).
  fun lv_deinit : Void

  # Returns the active screen object for the default display.
  #
  # Reference: [`lv_display.h`](lib/lvgl/src/display/lv_display.h).
  fun lv_screen_active : Pointer(LvObjT)

  # Legacy v8 API name kept in LVGL's API map.
  #
  # Reference mapping: [`lv_api_map_v8.h`](lib/lvgl/src/lv_api_map_v8.h).
  fun lv_scr_act = lv_screen_active : Pointer(LvObjT)

  # Create a base object.
  #
  # `parent` is the parent object. If `NULL`, LVGL creates a new screen object.
  # Reference: [`lv_obj.h`](lib/lvgl/src/core/lv_obj.h).
  fun lv_obj_create(parent : Pointer(LvObjT)) : Pointer(LvObjT)

  # Set object width and height in LVGL coordinate units.
  #
  # `w` and `h` are `lv_coord_t` values interpreted by LVGL layout/size rules.
  # Reference: [`lv_obj_pos.h`](lib/lvgl/src/core/lv_obj_pos.h).
  fun lv_obj_set_size(obj : Pointer(LvObjT), w : LvCoordT, h : LvCoordT) : Void

  # Align object to the center of its parent.
  #
  # Reference: [`lv_obj_pos.h`](lib/lvgl/src/core/lv_obj_pos.h).
  fun lv_obj_center(obj : Pointer(LvObjT)) : Void

  # Align object to a position inside its parent with optional x/y offsets.
  #
  # `align` is an `lv_align_t` value, and `x_ofs` / `y_ofs` are coordinate offsets
  # from the selected anchor.
  # Reference: [`lv_obj_pos.h`](lib/lvgl/src/core/lv_obj_pos.h).
  fun lv_obj_align(obj : Pointer(LvObjT), align : LvAlignT, x_ofs : LvCoordT, y_ofs : LvCoordT) : Void

  # Align object relative to another base object.
  #
  # `base` is the reference object used for anchor calculation.
  # Reference: [`lv_obj_pos.h`](lib/lvgl/src/core/lv_obj_pos.h).
  fun lv_obj_align_to(obj : Pointer(LvObjT), base : Pointer(LvObjT), align : LvAlignT, x_ofs : LvCoordT, y_ofs : LvCoordT) : Void
end
