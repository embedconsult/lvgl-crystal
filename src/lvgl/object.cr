require "./raw"
require "./runtime"

# Canonical Crystal wrapper around LVGL's base object pointer (`lv_obj_t *`).
#
# This class is the shared foundation for widget wrappers (for example,
# `Lvgl::Widgets::Label` and `Lvgl::Widgets::Button`) and for generic object
# tree operations.
#
# ## What this class is responsible for
#
# - Holding the raw LVGL pointer for one object instance.
# - Tracking the wrapper's parent relationship used when this object is created.
# - Starting LVGL runtime exactly once as object wrappers are constructed.
# - Exposing common object operations (`set_size`, `center`, `to_unsafe`).
# - Providing reusable constructor helpers for subclasses that need custom
#   `lv_*_create(...)` entry points.
#
# ## Ownership model
#
# LVGL owns object lifetime in C. This wrapper does not free objects directly.
# The wrapper behaves as a lightweight handle to a pointer managed by LVGL's
# object tree and runtime lifecycle.
#
# ## Runtime and threading expectations
#
# LVGL APIs assume a coordinated execution context. `Lvgl::Object` constructors
# call `Lvgl::Runtime.start` automatically (idempotent), so callers do not need
# to start runtime manually before creating the first object.
#
# Keep object manipulation on the same synchronized UI context used for other
# LVGL calls.
#
#
# ## Example
#
# ```
# # Runtime auto-starts on first object creation.
# root = Lvgl::Object.new(nil)
# label = Lvgl::Widgets::Label.new(root)
# label.text = "Hello"
#
# # Prefer explicit teardown when your app exits.
# Lvgl::Runtime.shutdown
# ```
# ## Authority links (for attribution)
#
# - LVGL object overview: https://docs.lvgl.io/9.4/overview/object.html
# - `lv_obj.h` API family: https://docs.lvgl.io/9.4/API/core/lv_obj.html
# - Positioning/sizing APIs: https://docs.lvgl.io/9.4/API/core/lv_obj_pos.html
class Lvgl::Object
  @@state_lock = Mutex.new
  @@instance_count = Atomic(Int32).new(0)

  @raw : Pointer(LibLvgl::LvObjT) = Pointer(LibLvgl::LvObjT).null
  @parent : Object? = nil

  # Returns number of currently-live Crystal wrapper instances.
  def self.instance_count : Int32
    @@instance_count.get
  end

  # Raw pointer accessor for the wrapped `lv_obj_t *`.
  #
  # ## What it does
  # Returns the currently stored LVGL pointer for this wrapper instance.
  #
  # ## Usage notes
  # - Primarily useful for low-level integration and diagnostics.
  # - Normal app code should prefer wrapper methods over raw pointer operations.
  #
  # ## Authority
  # - https://docs.lvgl.io/9.4/API/core/lv_obj.html
  def raw : Pointer(LibLvgl::LvObjT)
    @raw
  end

  # Raw pointer writer used by constructor helpers.
  #
  # ## What it does
  # Assigns the LVGL pointer stored in this wrapper.
  #
  # ## Usage notes
  # - Intended for internal construction paths (`allocate_with`).
  # - External code should not typically mutate object identity after creation.
  #
  # ## Authority
  # - https://docs.lvgl.io/9.4/API/core/lv_obj.html
  def raw=(value : Pointer(LibLvgl::LvObjT)) : Pointer(LibLvgl::LvObjT)
    @raw = value
  end

  # Parent-wrapper accessor.
  #
  # ## What it does
  # Returns the parent wrapper that was used during construction, when known.
  #
  # ## Usage notes
  # - `nil` is expected for wrappers representing active screen roots.
  # - This is metadata for wrapper-level composition and debugging.
  #
  # ## Authority
  # - https://docs.lvgl.io/9.4/overview/object.html
  def parent : Object?
    @parent
  end

  # Parent-wrapper writer used by constructor helpers.
  #
  # ## What it does
  # Stores parent metadata on this wrapper instance.
  #
  # ## Usage notes
  # - This does not reparent the LVGL object in C.
  # - Reparenting in LVGL would require explicit LVGL API calls.
  #
  # ## Authority
  # - https://docs.lvgl.io/9.4/overview/object.html
  def parent=(value : Object?) : Object?
    @parent = value
  end

  # Create a generic LVGL base object (`lv_obj_create`).
  #
  # ## What it does
  # Creates a new LVGL object and returns a wrapper for it.
  #
  # ## Parameters
  # - `parent`: Optional parent wrapper.
  #   - If non-`nil`, the object is created under that parent.
  #   - If `nil`, the active screen is resolved and used as the parent.
  #
  # ## Runtime behavior
  # Ensures `Lvgl::Runtime.start` has been called (idempotent).
  #
  # ## Authority
  # - https://docs.lvgl.io/9.4/API/core/lv_obj.html#c.lv_obj_create
  def self.new(parent : Object?) : Object
    build_with_parent(parent) do |parent_ptr|
      LibLvgl.lv_obj_create(parent_ptr)
    end
  end

  # Wrap the current active screen object.
  #
  # ## What it does
  # Returns an `Lvgl::Object` handle for LVGL's current active screen pointer.
  #
  # ## Usage notes
  # - Useful as an explicit parent when building trees.
  # - Returned wrapper has `parent == nil`.
  #
  # ## Runtime behavior
  # Ensures `Lvgl::Runtime.start` has been called (idempotent).
  #
  # ## Authority
  # - https://docs.lvgl.io/9.4/API/display/lv_display.html#c.lv_screen_active
  def self.screen_active : Object
    Lvgl::Runtime.start

    allocate_with(raw: LibLvgl.lv_screen_active, parent: nil)
  end

  # Set this object's width and height.
  #
  # ## What it does
  # Calls `lv_obj_set_size` with provided LVGL coordinate values.
  #
  # ## Parameters
  # - `width`: Horizontal size (`lv_coord_t`, typically pixels).
  # - `height`: Vertical size (`lv_coord_t`, typically pixels).
  #
  # ## Usage notes
  # LVGL layout and style rules can affect final rendered geometry.
  #
  # ## Authority
  # - https://docs.lvgl.io/9.4/API/core/lv_obj_pos.html#c.lv_obj_set_size
  def set_size(width : Int32, height : Int32) : Nil
    LibLvgl.lv_obj_set_size(@raw, width, height)
  end

  # Convenience tuple writer for object size (`{width, height}`).
  def size=(value : Tuple(Int32, Int32)) : Tuple(Int32, Int32)
    set_size(value[0], value[1])
    value
  end

  # Set this object's top-left position relative to its aligned parent space.
  def set_pos(x : Int32, y : Int32) : Nil
    LibLvgl.lv_obj_set_pos(@raw, x, y)
  end

  # Convenience tuple writer for object position (`{x, y}`).
  def pos=(value : Tuple(Int32, Int32)) : Tuple(Int32, Int32)
    set_pos(value[0], value[1])
    value
  end

  # Center this object in its current parent.
  #
  # ## What it does
  # Calls `lv_obj_center` for the wrapped LVGL object pointer.
  #
  # ## Usage notes
  # Equivalent to LVGL's shorthand centering helper.
  #
  # ## Authority
  # - https://docs.lvgl.io/9.4/API/core/lv_obj_pos.html#c.lv_obj_center
  def center : Nil
    LibLvgl.lv_obj_center(@raw)
  end

  # Align this object within its parent using an LVGL alignment selector.
  def align(align : Lvgl::Align, offset : Tuple(Int32, Int32) = {0, 0}) : Nil
    LibLvgl.lv_obj_align(@raw, align.to_i, offset[0], offset[1])
  end

  # Keyword-friendly overload for `align(..., offset: {x, y})` usage.
  def align(align : Lvgl::Align, *, offset : Tuple(Int32, Int32) = {0, 0}) : Nil
    align(align, offset)
  end

  # Returns a wrapped child object by index using LVGL's object tree order.
  def [](index : Int32) : Lvgl::Object
    child = LibLvgl.lv_obj_get_child(@raw, index)
    raise IndexError.new("#{index}") if child.null?

    self.class.allocate_with(raw: child, parent: self)
  end

  # Set background color style for this object and selector part/state.
  def set_style_bg_color(color : Lvgl::Color, selector : Lvgl::Part = Lvgl::Part::Main) : Nil
    LibLvgl.lv_obj_set_style_bg_color(@raw, color.to_unsafe, selector.to_i.to_u32)
  end

  # Keyword-friendly overload for `set_style_bg_color(..., selector: ...)`.
  def set_style_bg_color(color : Lvgl::Color, *, selector : Lvgl::Part = Lvgl::Part::Main) : Nil
    set_style_bg_color(color, selector)
  end

  # Set text color style for this object and selector part/state.
  def set_style_text_color(color : Lvgl::Color, selector : Lvgl::Part = Lvgl::Part::Main) : Nil
    LibLvgl.lv_obj_set_style_text_color(@raw, color.to_unsafe, selector.to_i.to_u32)
  end

  # Keyword-friendly overload for `set_style_text_color(..., selector: ...)`.
  def set_style_text_color(color : Lvgl::Color, *, selector : Lvgl::Part = Lvgl::Part::Main) : Nil
    set_style_text_color(color, selector)
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
  def text=(value : String) : String
    LibLvgl.lv_label_set_text(@raw, value)
    value
  end

  # Expose the wrapped pointer for FFI compatibility.
  #
  # ## What it does
  # Returns the raw pointer expected by Crystal's FFI interop conventions.
  #
  # ## Usage notes
  # Use this when calling an LVGL API that is not yet wrapped at higher level.
  #
  # ## Authority
  # - https://crystal-lang.org/reference/latest/syntax_and_semantics/c_bindings/index.html
  def to_unsafe : Pointer(LibLvgl::LvObjT)
    @raw
  end

  # Wrap a raw LVGL object pointer, returning `nil` for null pointers.
  def self.wrap(raw : Pointer(LibLvgl::LvObjT), parent : Object? = nil) : Object?
    return nil if raw.null?

    allocate_with(raw: raw, parent: parent)
  end

  # Shared constructor helper for classes that create LVGL objects.
  #
  # ## What it does
  # Enforces runtime initialization, resolves a parent, invokes the provided
  # creator block with `parent_ptr`, and allocates a typed wrapper instance.
  #
  # ## Parameters
  # - `parent`: Optional parent wrapper.
  # - Block: receives the parent pointer and must return a created `lv_obj_t *`.
  #
  # ## Intended usage
  # Subclasses use this to implement specialized constructors while sharing one
  # runtime-guard and allocation path.
  protected def self.build_with_parent(parent : Object?, & : Pointer(LibLvgl::LvObjT) -> Pointer(LibLvgl::LvObjT)) : self
    Lvgl::Runtime.start

    parent_obj = parent || screen_active
    raw = yield parent_obj.to_unsafe
    allocate_with(raw: raw, parent: parent_obj)
  end

  # Allocate and populate a wrapper instance without `initialize`.
  #
  # ## What it does
  # Creates an instance via `allocate`, assigns `raw` and `parent`, and returns
  # the correctly-typed wrapper (`self`).
  #
  # ## Intended usage
  # Internal constructor plumbing for `Object` and subclasses.
  protected def self.allocate_with(raw : Pointer(LibLvgl::LvObjT), parent : Object?) : self
    instance = allocate
    instance.raw = raw
    instance.parent = parent
    increment_instance_count!
    instance
  end

  # Called by GC before wrapper memory is reclaimed.
  def finalize : Nil
    self.class.decrement_instance_count!
  end

  def self.increment_instance_count! : Nil
    @@state_lock.synchronize do
      Lvgl::Runtime.start if @@instance_count.get == 0
      @@instance_count.add(1)
    end
  end

  def self.decrement_instance_count! : Nil
    @@state_lock.synchronize do
      return if @@instance_count.get <= 0

      @@instance_count.sub(1)
    end
  end
end
