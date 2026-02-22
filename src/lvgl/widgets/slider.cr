require "../object"

# Widget wrappers for LVGL built-in components.
module Lvgl::Widgets
  # Wrapper for LVGL's slider widget (`lv_slider_*`).
  class Slider < Lvgl::Object
    # Creates a new LVGL slider attached to `parent`.
    def self.new(parent : Lvgl::Object?) : self
      build_with_parent(parent) do |parent_ptr|
        LibLvgl.lv_slider_create(parent_ptr)
      end
    end

    # Returns the slider's current value.
    def value : Int32
      LibLvgl.lv_slider_get_value(to_unsafe)
    end

    # Sets the slider's value, optionally animating to the new position.
    def set_value(value : Int32, animated : Bool = false) : Nil
      LibLvgl.lv_slider_set_value(to_unsafe, value, animated ? 1_u8 : 0_u8)
    end

    # Convenience writer for setting slider value without animation.
    def value=(value : Int32) : Int32
      set_value(value)
      value
    end
  end
end
