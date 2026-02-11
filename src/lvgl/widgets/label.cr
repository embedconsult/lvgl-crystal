require "../object"

module Lvgl::Widgets
  # Wrapper for LVGL's label widget (`lv_label_*`).
  class Label
    # Raw pointer to LVGL's opaque widget object (`lv_obj_t*`).
    getter raw : Pointer(LibLvgl::LvObjT)

    private def initialize(@raw : Pointer(LibLvgl::LvObjT))
    end

    # ## What it does
    # Creates a new LVGL label under `parent`, or under the active screen when
    # `parent` is `nil`.
    #
    # ## Parameters
    # - `parent`: Optional parent object that owns this label in LVGL's object tree.
    #
    # ## Source credit
    # - Header: `lib/lvgl/src/widgets/label/lv_label.h` (`lv_label_create`)
    # - Project attribution: LVGL project (https://github.com/lvgl/lvgl)
    #
    # ## LVGL docs
    # - `/master/API/widgets/label/lv_label_h.html#_CPPv415lv_label_createP8lv_obj_t`
    def self.create(parent : Lvgl::Object?) : self
      ensure_runtime_initialized!

      parent_ptr = parent ? parent.to_unsafe : LibLvgl.lv_screen_active
      new(LibLvgl.lv_label_create(parent_ptr))
    end

    # ## What it does
    # Sets label text using LVGL's dynamic-text API (`lv_label_set_text`).
    #
    # LVGL copies the incoming UTF-8 bytes into its own internal buffer, so the
    # caller does **not** retain ownership requirements for `text` after the call.
    # LVGL expects a null-terminated C string and typically treats content as
    # UTF-8 for text rendering.
    #
    # ## Parameters
    # - `text`: Crystal `String` converted to a null-terminated C string.
    #
    # ## Source credit
    # - Header: `lib/lvgl/src/widgets/label/lv_label.h` (`lv_label_set_text`)
    # - Project attribution: LVGL project (https://github.com/lvgl/lvgl)
    #
    # ## LVGL docs
    # - `/master/API/widgets/label/lv_label_h.html#_CPPv417lv_label_set_textP8lv_obj_tPKc`
    def set_text(text : String) : Nil
      LibLvgl.lv_label_set_text(@raw, text)
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
