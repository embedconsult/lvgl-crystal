require "./raw"
require "./runtime"

# Canonical Crystal wrapper around LVGL's base object pointer (`lv_obj_t *`).
#
# ## Summary
# `Lvgl::Object` is the foundation for wrapper types such as
# `Lvgl::Widgets::Label` and `Lvgl::Widgets::Button`.
#
# Responsibilities:
# - Holds the raw LVGL pointer for one object instance.
# - Stores wrapper-level parent metadata used during construction.
# - Ensures `Lvgl::Runtime.start` has run before object creation paths.
# - Provides shared object APIs (`set_size`, `set_pos`, `center`, `align`, `to_unsafe`).
#
# ## Notes
# - LVGL owns C-side object lifetime; this wrapper does not free `lv_obj_t`.
# - Object mutation should stay on the synchronized LVGL/UI execution context.
#
# ## Example
# ```
# root = Lvgl::Object.new(nil)
# label = Lvgl::Widgets::Label.new(root)
# label.text = "Hello"
#
# # Prefer explicit teardown when your app exits.
# Lvgl::Runtime.shutdown
# ```
#
# ## Links
# - [LVGL object overview](https://docs.lvgl.io/9.4/API/core/lv_obj_h.html)
# - [LVGL object API](https://docs.lvgl.io/9.4/API/core/lv_obj_h.html)
# - [LVGL object header](https://github.com/embedconsult/lvgl/blob/v9.4.0/src/core/lv_obj.h)
class Lvgl::Object
  # Fluent style helper proxy bound to one `Lvgl::Object`.
  #
  # ## Summary
  # Provides concise style operations (`add`, `remove_all`, `radius`) while
  # preserving selector flexibility.
  #
  # ## Links
  # - [LVGL docs: object style API (9.4)](https://docs.lvgl.io/9.4/API/core/lv_obj_style_h.html)
  class StyleProxy
    alias SelectorInput = Lvgl::StyleSelector | Lvgl::State | Lvgl::Part | Int32 | UInt32

    # Create a style proxy bound to one target object.
    #
    # All proxy calls delegate immediately to methods on this `@object`.
    def initialize(@object : Lvgl::Object)
    end

    # Removes all styles attached through the style proxy target object.
    def remove_all : Nil
      @object.remove_style_all
    end

    # Adds one style to the style proxy target object with selector support.
    def add(style : Lvgl::Style, selector : SelectorInput = Lvgl.style_selector) : Nil
      @object.add_style(style, selector: selector)
    end

    # Adds one style to the style proxy target object with selector support.
    def add(style : Lvgl::Style, *, selector : SelectorInput = Lvgl.style_selector) : Nil
      add(style, selector)
    end

    # Sets style radius on the style proxy target object for the selector.
    def radius(value : Int32 | Lvgl::Radius, selector : SelectorInput = Lvgl.style_selector) : Nil
      radius_value = value.is_a?(Lvgl::Radius) ? value.to_i : value
      @object.set_style_radius(radius_value, normalize_selector(selector))
    end

    private def normalize_selector(selector : SelectorInput) : Lvgl::StyleSelector
      case selector
      when Lvgl::StyleSelector
        selector
      when Lvgl::State
        Lvgl.style_selector(state: selector)
      when Lvgl::Part
        Lvgl.style_selector(part: selector)
      when Int32
        Lvgl::StyleSelector.new(selector.to_u32)
      when UInt32
        Lvgl::StyleSelector.new(selector)
      else
        raise "Unsupported style selector input: #{selector.inspect}"
      end
    end
  end

  @@state_lock = Mutex.new
  @@instance_count = Atomic(Int32).new(0)

  @raw : Pointer(LibLvgl::LvObjT) = Pointer(LibLvgl::LvObjT).null
  @parent : Object? = nil
  @retained_styles : Array(Lvgl::Style)?

  # Returns number of currently-live Crystal wrapper instances.
  def self.instance_count : Int32
    @@instance_count.get
  end

  # Raw pointer accessor for the wrapped `lv_obj_t *`.
  #
  # ## Summary
  # Returns the currently stored LVGL pointer for this wrapper instance.
  #
  # ## Usage notes
  # - Primarily useful for low-level integration and diagnostics.
  # - Normal app code should prefer wrapper methods over raw pointer operations.
  #
  # ## Links
  # - [LVGL docs](https://docs.lvgl.io/9.4/API/core/lv_obj_h.html)
  def raw : Pointer(LibLvgl::LvObjT)
    @raw
  end

  # Raw pointer writer used by constructor helpers.
  #
  # ## Summary
  # Assigns the LVGL pointer stored in this wrapper.
  #
  # ## Usage notes
  # - Intended for internal construction paths (`allocate_with`).
  # - External code should not typically mutate object identity after creation.
  #
  # ## Links
  # - [LVGL docs](https://docs.lvgl.io/9.4/API/core/lv_obj_h.html)
  def raw=(value : Pointer(LibLvgl::LvObjT)) : Pointer(LibLvgl::LvObjT)
    @raw = value
  end

  # Parent-wrapper accessor.
  #
  # ## Summary
  # Returns the parent wrapper that was used during construction, when known.
  #
  # ## Usage notes
  # - `nil` is expected for wrappers representing active screen roots.
  # - This is metadata for wrapper-level composition and debugging.
  #
  # ## Links
  # - [LVGL docs](https://docs.lvgl.io/9.4/API/core/lv_obj_h.html)
  def parent : Object?
    @parent
  end

  # Parent-wrapper writer used by constructor helpers.
  #
  # ## Summary
  # Stores parent metadata on this wrapper instance.
  #
  # ## Usage notes
  # - This does not reparent the LVGL object in C.
  # - Reparenting in LVGL would require explicit LVGL API calls.
  #
  # ## Links
  # - [LVGL docs](https://docs.lvgl.io/9.4/API/core/lv_obj_h.html)
  def parent=(value : Object?) : Object?
    @parent = value
  end

  # Create a generic LVGL base object (`lv_obj_create`).
  #
  # ## Summary
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
  # ## Links
  # - [LVGL docs](https://docs.lvgl.io/9.4/API/core/lv_obj_h.html#c.lv_obj_create)
  def self.new(parent : Object?) : Object
    build_with_parent(parent) do |parent_ptr|
      LibLvgl.lv_obj_create(parent_ptr)
    end
  end

  # Wrap the current active screen object.
  #
  # ## Summary
  # Returns an `Lvgl::Object` handle for LVGL's current active screen pointer.
  #
  # ## Usage notes
  # - Useful as an explicit parent when building trees.
  # - Returned wrapper has `parent == nil`.
  #
  # ## Runtime behavior
  # Ensures `Lvgl::Runtime.start` has been called (idempotent).
  #
  # ## Links
  # - [LVGL docs](https://docs.lvgl.io/9.4/API/display/lv_display_h.html#c.lv_screen_active)
  def self.screen_active : Object
    Lvgl::Runtime.start

    allocate_with(raw: LibLvgl.lv_screen_active, parent: nil)
  end

  # Set this object's width and height.
  #
  # ## Summary
  # Calls `lv_obj_set_size` with provided LVGL coordinate values.
  #
  # ## Parameters
  # - `width`: Horizontal size (`lv_coord_t`, typically pixels).
  # - `height`: Vertical size (`lv_coord_t`, typically pixels).
  #
  # ## Usage notes
  # LVGL layout and style rules can affect final rendered geometry.
  #
  # ## Links
  # - [LVGL docs](https://docs.lvgl.io/9.4/API/core/lv_obj_pos_h.html#c.lv_obj_set_size)
  def set_size(width : Int32, height : Int32) : Nil
    LibLvgl.lv_obj_set_size(@raw, width, height)
  end

  # Convenience tuple writer for object size (`{width, height}`).
  def size=(value : Tuple(Int32, Int32)) : Tuple(Int32, Int32)
    set_size(value[0], value[1])
    value
  end

  # Set this object's top-left position relative to parent content coordinates.
  #
  # ## Summary
  # Calls `lv_obj_set_pos` with LVGL coordinate values.
  #
  # ## Parameters
  # - `x`: Horizontal offset in `lv_coord_t` units.
  # - `y`: Vertical offset in `lv_coord_t` units.
  #
  # ## Results
  # - Updates this object's LVGL position state.
  #
  # ## Links
  # - [LVGL docs](https://docs.lvgl.io/9.4/API/core/lv_obj_pos_h.html#c.lv_obj_set_pos)
  def set_pos(x : Int32, y : Int32) : Nil
    LibLvgl.lv_obj_set_pos(@raw, x, y)
  end

  # Convenience tuple writer for object position (`{x, y}`).
  #
  # ## Parameters
  # - `value`: Position tuple where `value[0]` is x and `value[1]` is y.
  #
  # ## Results
  # - Returns: The original tuple, after applying `set_pos`.
  def pos=(value : Tuple(Int32, Int32)) : Tuple(Int32, Int32)
    set_pos(value[0], value[1])
    value
  end

  # Convenience tuple writer alias for object position (`{x, y}`).
  def position=(value : Tuple(Int32, Int32)) : Tuple(Int32, Int32)
    self.pos = value
  end

  # Center this object in its current parent.
  #
  # ## Summary
  # Calls `lv_obj_center` for the wrapped LVGL object pointer.
  #
  # ## Usage notes
  # Equivalent to LVGL's shorthand centering helper.
  #
  # ## Links
  # - [LVGL docs](https://docs.lvgl.io/9.4/API/core/lv_obj_pos_h.html#c.lv_obj_center)
  def center : Nil
    LibLvgl.lv_obj_center(@raw)
  end

  # Align this object within its parent using an LVGL alignment selector.
  #
  # ## Parameters
  # - `align`: Anchor selector from `Lvgl::Align`.
  # - `offset`: Optional x/y coordinate offsets from the selected anchor.
  #
  # ## Results
  # - Updates this object's LVGL alignment state.
  #
  # ## Links
  # - [LVGL docs](https://docs.lvgl.io/9.4/API/core/lv_obj_pos_h.html#c.lv_obj_align)
  def align(align : Lvgl::Align, offset : Tuple(Int32, Int32) = {0, 0}) : Nil
    LibLvgl.lv_obj_align(@raw, align.to_i, offset[0], offset[1])
  end

  # Keyword-friendly overload for `align(..., offset: {x, y})` usage.
  #
  # ## Results
  # - Delegates to `#align(align, offset)`.
  def align(align : Lvgl::Align, *, offset : Tuple(Int32, Int32) = {0, 0}) : Nil
    align(align, offset)
  end

  # Returns a wrapped child object by index using LVGL's object tree order.
  #
  # ## Parameters
  # - `index`: Child index in LVGL tree ordering.
  #
  # ## Results
  # - Returns: Wrapped child object when index exists.
  # - Raises: `IndexError` when LVGL returns a null child pointer.
  #
  # ## Links
  # - [LVGL docs](https://docs.lvgl.io/9.4/API/core/lv_obj_tree_h.html#c.lv_obj_get_child)
  def [](index : Int32) : Lvgl::Object
    child = LibLvgl.lv_obj_get_child(@raw, index)
    raise IndexError.new("#{index}") if child.null?

    self.class.allocate_with(raw: child, parent: self)
  end

  # Set background color style for this object and selector part/state.
  #
  # ## Parameters
  # - `color`: Background color value.
  # - `selector`: Style selector/part mask; defaults to main/default selector.
  #
  # ## Results
  # - Updates style state for the selected part/state.
  #
  # ## Links
  # - [LVGL docs](https://docs.lvgl.io/9.4/API/core/lv_obj_style_gen_h.html#_CPPv425lv_obj_set_style_bg_colorP8lv_obj_t10lv_color_t19lv_style_selector_t)
  def set_style_bg_color(color : Lvgl::Color, selector : Lvgl::StyleSelector = Lvgl.style_selector) : Nil
    LibLvgl.lv_obj_set_style_bg_color(@raw, color.to_unsafe, selector.to_unsafe)
  end

  # Compatibility overload for callers using part-only selectors.
  def set_style_bg_color(color : Lvgl::Color, selector : Lvgl::Part) : Nil
    set_style_bg_color(color, Lvgl.style_selector(part: selector))
  end

  # Keyword-friendly overload for `set_style_bg_color(..., selector: ...)`.
  #
  # ## Results
  # - Delegates to positional-argument overload.
  def set_style_bg_color(color : Lvgl::Color, *, selector : Lvgl::StyleSelector = Lvgl.style_selector) : Nil
    set_style_bg_color(color, selector)
  end

  # Set text color style for this object and selector part/state.
  #
  # ## Parameters
  # - `color`: Text color value.
  # - `selector`: Style selector/part mask; defaults to main/default selector.
  #
  # ## Results
  # - Updates style state for the selected part/state.
  #
  # ## Links
  # - [LVGL docs](https://docs.lvgl.io/9.4/API/core/lv_obj_style_gen_h.html#_CPPv427lv_obj_set_style_text_colorP8lv_obj_t10lv_color_t19lv_style_selector_t)
  def set_style_text_color(color : Lvgl::Color, selector : Lvgl::StyleSelector = Lvgl.style_selector) : Nil
    LibLvgl.lv_obj_set_style_text_color(@raw, color.to_unsafe, selector.to_unsafe)
  end

  # Compatibility overload for callers using part-only selectors.
  def set_style_text_color(color : Lvgl::Color, selector : Lvgl::Part) : Nil
    set_style_text_color(color, Lvgl.style_selector(part: selector))
  end

  # Keyword-friendly overload for `set_style_text_color(..., selector: ...)`.
  #
  # ## Results
  # - Delegates to positional-argument overload.
  def set_style_text_color(color : Lvgl::Color, *, selector : Lvgl::StyleSelector = Lvgl.style_selector) : Nil
    set_style_text_color(color, selector)
  end

  # Remove all currently attached styles from this object.
  def remove_style_all : Nil
    LibLvgl.lv_obj_remove_style_all(@raw)
    @retained_styles.try &.clear
  end

  # Add one style descriptor to this object for one selector mask.
  def add_style(
    style : Lvgl::Style,
    selector : Lvgl::StyleSelector | Lvgl::State | Lvgl::Part | Int32 | UInt32 = Lvgl.style_selector,
  ) : Nil
    resolved_selector = case selector
                        when Lvgl::StyleSelector
                          selector
                        when Lvgl::State
                          Lvgl.style_selector(state: selector)
                        when Lvgl::Part
                          Lvgl.style_selector(part: selector)
                        when Int32
                          Lvgl::StyleSelector.new(selector.to_u32)
                        when UInt32
                          Lvgl::StyleSelector.new(selector)
                        else
                          raise "Unsupported style selector input: #{selector.inspect}"
                        end

    LibLvgl.lv_obj_add_style(@raw, style.to_unsafe, resolved_selector.to_unsafe)
    retained_styles << style unless retained_styles.includes?(style)
  end

  # Keyword-friendly overload for `add_style(..., selector: ...)`.
  def add_style(
    style : Lvgl::Style,
    *,
    selector : Lvgl::StyleSelector | Lvgl::State | Lvgl::Part | Int32 | UInt32 = Lvgl.style_selector,
  ) : Nil
    add_style(style, selector)
  end

  # Add one or more states to this object.
  def add_state(state : Lvgl::State) : Nil
    LibLvgl.lv_obj_add_state(@raw, state.to_i.to_u32)
  end

  # Remove one or more states from this object.
  def remove_state(state : Lvgl::State) : Nil
    LibLvgl.lv_obj_remove_state(@raw, state.to_i.to_u32)
  end

  # Resolve one style property for this object and part in the current state.
  def get_style_prop(part : Lvgl::Part, prop : Lvgl::StyleProp) : LibLvgl::LvStyleValueT
    LibLvgl.lv_obj_get_style_prop(@raw, part.to_i.to_u32, prop.to_i.to_u8)
  end

  # Apply active color filter(s) to a resolved style value for this object/part.
  def apply_style_color_filter(part : Lvgl::Part, value : LibLvgl::LvStyleValueT) : LibLvgl::LvStyleValueT
    LibLvgl.lv_obj_style_apply_color_filter(@raw, part.to_i.to_u32, value)
  end

  # Fluent style helper proxy.
  def style : StyleProxy
    StyleProxy.new(self)
  end

  # Set background opacity for a selector.
  def set_style_bg_opa(value : Lvgl::Opa | UInt8, selector : Lvgl::StyleSelector = Lvgl.style_selector) : Nil
    opacity = value.is_a?(Lvgl::Opa) ? value.to_i.to_u8 : value
    LibLvgl.lv_obj_set_style_bg_opa(@raw, opacity, selector.to_unsafe)
  end

  # Set gradient color for a selector.
  def set_style_bg_grad_color(color : Lvgl::Color, selector : Lvgl::StyleSelector = Lvgl.style_selector) : Nil
    LibLvgl.lv_obj_set_style_bg_grad_color(@raw, color.to_unsafe, selector.to_unsafe)
  end

  # Set gradient direction for a selector.
  def set_style_bg_grad_dir(dir : Lvgl::GradDir | Lvgl::GradientDirection, selector : Lvgl::StyleSelector = Lvgl.style_selector) : Nil
    normalized = dir.is_a?(Lvgl::GradientDirection) ? dir.to_grad_dir : dir
    LibLvgl.lv_obj_set_style_bg_grad_dir(@raw, normalized.to_i, selector.to_unsafe)
  end

  # Set border color for a selector.
  def set_style_border_color(color : Lvgl::Color, selector : Lvgl::StyleSelector = Lvgl.style_selector) : Nil
    LibLvgl.lv_obj_set_style_border_color(@raw, color.to_unsafe, selector.to_unsafe)
  end

  # Set border opacity for a selector.
  def set_style_border_opa(value : Lvgl::Opa | UInt8, selector : Lvgl::StyleSelector = Lvgl.style_selector) : Nil
    opacity = value.is_a?(Lvgl::Opa) ? value.to_i.to_u8 : value
    LibLvgl.lv_obj_set_style_border_opa(@raw, opacity, selector.to_unsafe)
  end

  # Set border width for a selector.
  def set_style_border_width(value : Int32, selector : Lvgl::StyleSelector = Lvgl.style_selector) : Nil
    LibLvgl.lv_obj_set_style_border_width(@raw, value, selector.to_unsafe)
  end

  # Set corner radius for a selector.
  def set_style_radius(value : Int32, selector : Lvgl::StyleSelector = Lvgl.style_selector) : Nil
    LibLvgl.lv_obj_set_style_radius(@raw, value, selector.to_unsafe)
  end

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
  # - `value`: UTF-8 string passed to LVGL label text API for new label content.
  #   Existing dynamic text is released by LVGL and
  #   replaced with a freshly allocated copy of `value`.
  #
  # ## Results
  # - Replaces underlying label text through LVGL.
  # - Returns: The original assigned string value.
  #
  # ## Links
  # - [LVGL docs](https://docs.lvgl.io/9.4/API/widgets/label/lv_label_h.html#c.lv_label_set_text)
  # - [LVGL header](https://github.com/embedconsult/lvgl/blob/v9.4.0/src/widgets/label/lv_label.h)
  def text=(value : String) : String
    LibLvgl.lv_label_set_text(@raw, value)
    value
  end

  # Expose the wrapped pointer for FFI compatibility.
  #
  # ## Summary
  # Returns the raw pointer expected by Crystal's FFI interop conventions.
  #
  # ## Usage notes
  # Use this when calling an LVGL API that is not yet wrapped at higher level.
  #
  # ## Links
  # - [Crystal C bindings](https://crystal-lang.org/reference/latest/syntax_and_semantics/c_bindings/index.html)
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
  # ## Summary
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
  # ## Summary
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
    @retained_styles.try &.clear
    self.class.decrement_instance_count!
  end

  private def retained_styles : Array(Lvgl::Style)
    @retained_styles ||= [] of Lvgl::Style
  end

  private def self.increment_instance_count! : Nil
    @@state_lock.synchronize do
      Lvgl::Runtime.start if @@instance_count.get == 0
      @@instance_count.add(1)
    end
  end

  private def self.decrement_instance_count! : Nil
    @@state_lock.synchronize do
      return if @@instance_count.get <= 0

      @@instance_count.sub(1)
    end
  end
end
