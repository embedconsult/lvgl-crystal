require "../object"

module Lvgl::Widgets
  # Wrapper for LVGL's label widget (`lv_label_*`).
  class Label
    # Raw pointer to LVGL's underlying widget object (`lv_obj_t*`).
    delegate raw, to_unsafe, to: @object

    protected def initialize(@object : Lvgl::Object)
    end

    # ## What it does
    # Creates a new LVGL label (`lv_label_create`) attached to `parent`.
    #
    # If `parent` is `nil`, this uses `Lvgl::Object.screen_active` as parent so
    # the label is added to the active screen.
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
      ensure_runtime_initialized!

      parent_obj = parent || Lvgl::Object.screen_active
      raw_label = LibLvgl.lv_label_create(parent_obj.to_unsafe)

      allocate.tap do |instance|
        instance.initialize(Lvgl::Object.from_raw(raw_label))
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
    # - In this binding we treat it as UTF-8 text, matching Crystal `String`
    #   encoding and LVGL's standard text-rendering expectations.
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
      LibLvgl.lv_label_set_text(@object.to_unsafe, text)
    end

    private def self.ensure_runtime_initialized! : Nil
      return if Lvgl::Runtime.initialized?

      raise "Lvgl::Runtime.init must be called before creating Lvgl::Widgets::Label instances"
    end
  end
end
