require "../object"

module Lvgl::Widgets
  # Wrapper for LVGL's button widget (`lv_button_*`).
  class Button
    # Raw pointer to LVGL's opaque widget object (`lv_obj_t*`).
    getter raw : Pointer(LibLvgl::LvObjT)

    private def initialize(@raw : Pointer(LibLvgl::LvObjT))
    end

    # ## What it does
    # Creates a new LVGL button under `parent`, or under the active screen when
    # `parent` is `nil`.
    #
    # ## Parameters
    # - `parent`: Optional parent object that owns this button in LVGL's object tree.
    #
    # ## Source credit
    # - Header: `lib/lvgl/src/widgets/button/lv_button.h` (`lv_button_create`)
    # - Project attribution: LVGL project (https://github.com/lvgl/lvgl)
    #
    # ## LVGL docs
    # - `/master/API/widgets/button/lv_button_h.html#_CPPv416lv_button_createP8lv_obj_t`
    def self.create(parent : Lvgl::Object?) : self
      ensure_runtime_initialized!

      parent_ptr = parent ? parent.to_unsafe : LibLvgl.lv_screen_active
      new(LibLvgl.lv_button_create(parent_ptr))
    end

    # ## What it does
    # Sets this button's width and height via LVGL object sizing.
    #
    # ## Parameters
    # - `width`: Width in LVGL coordinate units (`lv_coord_t`).
    # - `height`: Height in LVGL coordinate units (`lv_coord_t`).
    #
    # ## Source credit
    # - Header: `lib/lvgl/src/core/lv_obj_pos.h` (`lv_obj_set_size`)
    # - Project attribution: LVGL project (https://github.com/lvgl/lvgl)
    #
    # ## LVGL docs
    # - `/master/API/core/lv_obj_pos_h.html#_CPPv415lv_obj_set_sizeP8lv_obj_t10lv_coord_t10lv_coord_t`
    def set_size(width : Int32, height : Int32) : Nil
      LibLvgl.lv_obj_set_size(@raw, width, height)
    end

    private def self.ensure_runtime_initialized! : Nil
      return if Lvgl::Runtime.initialized?

      raise "Lvgl::Runtime.init must be called before creating Lvgl::Widgets instances"
    end

    # Returns the wrapped pointer for low-level FFI calls.
    def to_unsafe : Pointer(LibLvgl::LvObjT)
      @raw
    end
  end
end
