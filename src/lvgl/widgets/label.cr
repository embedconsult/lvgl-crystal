require "../object"

# Widget wrappers for LVGL built-in components.
module Lvgl::Widgets
  # Wrapper for LVGL's label widget (`lv_label_*`).
  class Label < Lvgl::Object
    # ## Summary
    # Creates a new LVGL label (`lv_label_create`) attached to `parent`.
    #
    # If `parent` is `nil`, LVGL uses the active screen as parent.
    #
    # ## Parameters
    # - `parent`: Optional parent object in the LVGL object tree.
    #
    # ## Links
    # - [LVGL docs](https://docs.lvgl.io/9.4/API/widgets/label/lv_label.html#c.lv_label_create)
    # - [LVGL header](https://github.com/embedconsult/lvgl/blob/v9.4.0/src/widgets/label/lv_label.h)
    def self.new(parent : Lvgl::Object?) : self
      build_with_parent(parent) do |parent_ptr|
        LibLvgl.lv_label_create(parent_ptr)
      end
    end

    # ## Summary
    # Replaces the label text using LVGL's dynamic string API (`lv_label_set_text`).
    #
    # The provided Crystal `String` is converted to a null-terminated C string and
    # passed to LVGL. LVGL copies the bytes into a new internal buffer, so the
    # caller can immediately let the original Crystal string go out of scope.
    #
    # Encoding assumptions:
    # - LVGL expects text as `const char *`.
    # - This wrapper passes Crystal strings as UTF-8 text.
    #
    # ## Parameters
    # - `text`: New label content. Existing dynamic text is released by LVGL and
    #   replaced with a freshly allocated copy of `text`.
    #
    # ## Links
    # - [LVGL docs](https://docs.lvgl.io/9.4/API/widgets/label/lv_label.html#c.lv_label_set_text)
    # - [LVGL header](https://github.com/embedconsult/lvgl/blob/v9.4.0/src/widgets/label/lv_label.h)
    def set_text(text : String) : Nil
      super(text)
    end

    # Property-style alias for `set_text`.
    def text=(value : String) : String
      set_text(value)
      value
    end
  end
end
