require "./raw"

# Lightweight wrapper over `lv_obj_t*`.
#
# API references:
# - [`lv_obj.h`](lib/lvgl/src/core/lv_obj.h)
# - [`lv_obj_pos.h`](lib/lvgl/src/core/lv_obj_pos.h)
class Lvgl::Object
  getter raw : Pointer(LibLvgl::LvObjT)

  def initialize(@raw : Pointer(LibLvgl::LvObjT))
  end

  # Create a base LVGL object.
  #
  # `parent` is the parent object. Pass `nil` to create a screen object.
  # Size and position are handled by LVGL after creation.
  def self.create(parent : Object?) : Object
    parent_ptr = parent ? parent.to_unsafe : Pointer(LibLvgl::LvObjT).null
    new(LibLvgl.lv_obj_create(parent_ptr))
  end

  # Set object width and height in LVGL coordinate units.
  #
  # `width` and `height` map to LVGL's `w` and `h` (`lv_coord_t`) parameters in
  # `lv_obj_set_size`.
  def set_size(width : Int32, height : Int32) : Nil
    LibLvgl.lv_obj_set_size(@raw, width, height)
  end

  # Center this object in its parent object.
  def center : Nil
    LibLvgl.lv_obj_center(@raw)
  end

  def to_unsafe : Pointer(LibLvgl::LvObjT)
    @raw
  end
end
