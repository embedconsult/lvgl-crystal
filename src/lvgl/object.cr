require "./raw"
require "./runtime"

# Lightweight wrapper over `lv_obj_t*`.
#
# API references:
# - [`lv_obj.h`](lib/lvgl/src/core/lv_obj.h)
# - [`lv_obj_pos.h`](lib/lvgl/src/core/lv_obj_pos.h)
# - [`lv_label.h`](lib/lvgl/src/widgets/label/lv_label.h)
# - [`lv_button.h`](lib/lvgl/src/widgets/button/lv_button.h)
#
# ## Why this wrapper exists
#
# LVGL's C API is pointer-oriented. In Crystal, this class provides a tiny,
# intentional API around `Pointer(LibLvgl::LvObjT)` so app code can stay focused
# on GUI intent rather than repetitive pointer plumbing.
#
# ## Typical usage
#
# ```
# require "lvgl-crystal"
#
# Lvgl::Runtime.init
#
# panel = Lvgl::Object.new(nil) # child of current active screen
# panel.set_size(240, 120)      # LVGL coordinate units (`lv_coord_t`)
# panel.center                  # center in parent
#
# # ... run your LVGL loop ...
#
# Lvgl::Runtime.deinit
# ```
#
# ## Runtime precondition
#
# Object creation requires a live LVGL runtime. This wrapper raises if
# `Lvgl::Runtime.init` has not been called yet, which helps catch lifecycle
# mistakes early in application startup.
class Lvgl::Object
  # Raw pointer to LVGL's opaque `lv_obj_t`.
  #
  # Advanced integrations can pass this to low-level bindings that are not yet
  # wrapped at the Crystal layer.
  getter raw : Pointer(LibLvgl::LvObjT)

  protected def initialize(@raw : Pointer(LibLvgl::LvObjT))
  end

  # Create a base LVGL object.
  #
  # - `parent`: Parent object pointer owner.
  #   - Pass an `Object` to create a child object under that parent.
  #   - Pass `nil` to use the current active screen as parent (via
  #     `lv_screen_active`) and create a top-level widget with less boilerplate.
  # - Returns: A wrapped `Lvgl::Object` for the newly-created `lv_obj_t`.
  #
  # This method requires that `Lvgl::Runtime.init` has already been called.
  def self.new(parent : Object?) : Object
    ensure_runtime_initialized!

    parent_ptr = parent ? parent.to_unsafe : lv_screen_active_ptr
    new(LibLvgl.lv_obj_create(parent_ptr))
  end

  # Return a wrapper around LVGL's current active screen object.
  #
  # This can be used as an explicit parent when composing object trees.
  def self.screen_active : Object
    ensure_runtime_initialized!

    new(lv_screen_active_ptr)
  end

  # Create an LVGL label object and return it as `Lvgl::Object`.
  #
  # Higher-level wrappers should call this instead of using `LibLvgl` directly.
  def self.new_label(parent : Object?) : Object
    ensure_runtime_initialized!

    parent_ptr = parent ? parent.to_unsafe : lv_screen_active_ptr
    new(LibLvgl.lv_label_create(parent_ptr))
  end

  # Create an LVGL button object and return it as `Lvgl::Object`.
  #
  # Higher-level wrappers should call this instead of using `LibLvgl` directly.
  def self.new_button(parent : Object?) : Object
    ensure_runtime_initialized!

    parent_ptr = parent ? parent.to_unsafe : lv_screen_active_ptr
    new(LibLvgl.lv_button_create(parent_ptr))
  end

  # Set label text on this object using LVGL's dynamic text API.
  #
  # LVGL copies the bytes of `text` to internal storage.
  def set_label_text(text : String) : Nil
    LibLvgl.lv_label_set_text(@raw, text)
  end

  # Set object width and height in LVGL coordinate units (`lv_coord_t`).
  #
  # - `width`: Horizontal object size passed as `w` in `lv_obj_set_size`.
  # - `height`: Vertical object size passed as `h` in `lv_obj_set_size`.
  #
  # LVGL interprets these values according to its layout engine and style rules.
  # In common pixel-coordinate setups they are pixel values, but LVGL also
  # supports transformed units through helper macros on the C side.
  def set_size(width : Int32, height : Int32) : Nil
    LibLvgl.lv_obj_set_size(@raw, width, height)
  end

  # Center this object in its parent object.
  #
  # Equivalent to calling `lv_obj_center(obj)` from LVGL.
  def center : Nil
    LibLvgl.lv_obj_center(@raw)
  end

  # Returns the wrapped pointer for FFI calls.
  #
  # This is the standard Crystal FFI escape hatch method used when a higher-level
  # wrapper is not yet available for a specific LVGL function.
  def to_unsafe : Pointer(LibLvgl::LvObjT)
    @raw
  end

  private def self.lv_screen_active_ptr : Pointer(LibLvgl::LvObjT)
    LibLvgl.lv_screen_active
  end

  protected def self.ensure_runtime_initialized! : Nil
    return if Lvgl::Runtime.initialized?

    raise "Lvgl::Runtime.init must be called before creating Lvgl::Object instances"
  end
end
