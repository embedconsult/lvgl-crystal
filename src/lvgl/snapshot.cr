require "file_utils"
require "./raw"
require "./types"
require "./object"

module Lvgl
  module Snapshot
    def self.save_object(obj : Lvgl::Object, path : String, color_format : Lvgl::ColorFormat = Lvgl::ColorFormat::Argb8888) : Nil
      draw_buf = LibLvgl.lv_snapshot_take(obj.raw, color_format.value)
      raise "Failed to snapshot active screen" if draw_buf.null?

      begin
        FileUtils.mkdir_p(File.dirname(path))
        result = LibLvgl.lv_draw_buf_save_to_file(draw_buf, path)
        unless result == Lvgl::Result::Ok.value
          raise "Failed to save snapshot to '#{path}' (lv_result_t=#{result})"
        end
      ensure
        LibLvgl.lv_draw_buf_destroy(draw_buf)
      end
    end

    def self.save_screen(path : String, color_format : Lvgl::ColorFormat = Lvgl::ColorFormat::Argb8888) : Nil
      save_object(Lvgl::Object.screen_active, path, color_format)
    end
  end
end
