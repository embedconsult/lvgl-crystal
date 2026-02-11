require "../object"

module Lvgl::Widgets
  # Wrapper for LVGL's button widget (`lv_button_*`).
  class Button < Lvgl::Object
    # ## What it does
    # Creates a new LVGL button (`lv_button_create`) attached to `parent`.
    #
    # If `parent` is `nil`, LVGL uses the active screen as parent.
    #
    # ## Parameters
    # - `parent`: Optional parent object in the LVGL object tree.
    #
    # ## Source credit
    # - Header: `lib/lvgl/src/widgets/button/lv_button.h` (`lv_button_create`)
    # - Project attribution: LVGL project (https://github.com/lvgl/lvgl)
    #
    # ## LVGL docs
    # - https://docs.lvgl.io/9.4/API/widgets/button/lv_button.html#c.lv_button_create
    def self.new(parent : Lvgl::Object?) : self
      build_with_parent(parent) do |parent_ptr|
        LibLvgl.lv_button_create(parent_ptr)
      end
    end

    # ## What it does
    # Sets this button's width and height in LVGL coordinate units.
    #
    # This calls LVGL's `lv_obj_set_size` and applies LVGL layout rules to the
    # size values.
    #
    # ## Parameters
    # - `width`: Width in `lv_coord_t` units (typically pixels).
    # - `height`: Height in `lv_coord_t` units (typically pixels).
    #
    # ## Source credit
    # - Header: `lib/lvgl/src/core/lv_obj_pos.h` (`lv_obj_set_size`)
    # - Project attribution: LVGL project (https://github.com/lvgl/lvgl)
    #
    # ## LVGL docs
    # - https://docs.lvgl.io/9.4/API/core/lv_obj_pos.html#c.lv_obj_set_size
    def set_size(width : Int32, height : Int32) : Nil
      super(width, height)
    end
  end
end
