require "../object"

module Lvgl::Widgets
  # Wrapper for LVGL's label widget (`lv_label_*`).
  class Label < Lvgl::Object
    # ## What it does
    # Creates a new LVGL label (`lv_label_create`) attached to `parent`.
    #
    # If `parent` is `nil`, LVGL uses the active screen as parent.
    #
    # ## Parameters
    # - `parent`: Optional parent object in the LVGL object tree.
    #
    # ## Source credit
    # - Header: `lib/lvgl/src/widgets/label/lv_label.h` (`lv_label_create`)
    # - Project attribution: LVGL project (https://github.com/lvgl/lvgl)
    #
    # ## LVGL docs
    # - https://docs.lvgl.io/9.4/API/widgets/label/lv_label.html#c.lv_label_create
    def self.new(parent : Lvgl::Object?) : self
      build_with_parent(parent) do |parent_ptr|
        LibLvgl.lv_label_create(parent_ptr)
      end
    end

    # ## What it does
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
    # ## Source credit
    # - Header: `lib/lvgl/src/widgets/label/lv_label.h` (`lv_label_set_text`)
    # - Project attribution: LVGL project (https://github.com/lvgl/lvgl)
    #
    # ## LVGL docs
    # - https://docs.lvgl.io/9.4/API/widgets/label/lv_label.html#c.lv_label_set_text
    def set_text(text : String) : Nil
      LibLvgl.lv_label_set_text(@raw, text)
    end
  end
end
