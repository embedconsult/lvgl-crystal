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
  end
end
