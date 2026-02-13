require "../object"

# Widget wrappers for LVGL built-in components.
module Lvgl::Widgets
  # Wrapper for LVGL's button widget (`lv_button_*`).
  class Button < Lvgl::Object
    # ## Summary
    # Creates a new LVGL button (`lv_button_create`) attached to `parent`.
    #
    # If `parent` is `nil`, LVGL uses the active screen as parent.
    #
    # ## Parameters
    # - `parent`: Optional parent object in the LVGL object tree.
    #
    # ## Links
    # - [LVGL docs](https://docs.lvgl.io/9.4/API/widgets/button/lv_button.html#c.lv_button_create)
    # - [LVGL header](https://github.com/embedconsult/lvgl/blob/v9.4.0/src/widgets/button/lv_button.h)
    def self.new(parent : Lvgl::Object?) : self
      build_with_parent(parent) do |parent_ptr|
        LibLvgl.lv_button_create(parent_ptr)
      end
    end

    # ## Summary
    # Sets this button's width and height in LVGL coordinate units.
    #
    # This calls LVGL's `lv_obj_set_size` and applies LVGL layout rules to the
    # size values.
    #
    # ## Parameters
    # - `width`: Width in `lv_coord_t` units (typically pixels).
    # - `height`: Height in `lv_coord_t` units (typically pixels).
    #
    # ## Links
    # - [LVGL docs](https://docs.lvgl.io/9.4/API/core/lv_obj_pos.html#c.lv_obj_set_size)
    # - [LVGL header](https://github.com/embedconsult/lvgl/blob/v9.4.0/src/core/lv_obj_pos.h)
    def set_size(width : Int32, height : Int32) : Nil
      super(width, height)
    end
  end
end
