require "../object"

module Lvgl::Widgets
  # Wrapper for LVGL's button widget (`lv_button_*`).
  class Button
    # Raw pointer to LVGL's underlying widget object (`lv_obj_t*`).
    delegate raw, to_unsafe, to: @object

    protected def initialize(@object : Lvgl::Object)
    end

    # ## What it does
    # Creates a new LVGL button (`lv_button_create`) attached to `parent`.
    #
    # If `parent` is `nil`, this uses `Lvgl::Object.screen_active` as parent so
    # the button is added to the active screen.
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
      ensure_runtime_initialized!

      parent_obj = parent || Lvgl::Object.screen_active
      raw_button = LibLvgl.lv_button_create(parent_obj.to_unsafe)

      allocate.tap do |instance|
        instance.initialize(Lvgl::Object.from_raw(raw_button))
      end
    end

    # ## What it does
    # Sets this button's width and height in LVGL coordinate units.
    #
    # This delegates to `Lvgl::Object#set_size`, which calls LVGL's
    # `lv_obj_set_size` and applies LVGL layout rules to the size values.
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
      @object.set_size(width, height)
    end

    private def self.ensure_runtime_initialized! : Nil
      return if Lvgl::Runtime.initialized?

      raise "Lvgl::Runtime.init must be called before creating Lvgl::Widgets::Button instances"
    end
  end
end
