require "compress/zlib"
require "digest/crc32"
require "file_utils"
require "io/byte_format"
require "io/memory"
require "./raw"
require "./types"
require "./object"

module Lvgl
  module Snapshot
    private PNG_SIGNATURE = Bytes[137_u8, 80_u8, 78_u8, 71_u8, 13_u8, 10_u8, 26_u8, 10_u8]

    def self.save_object(obj : Lvgl::Object, path : String, color_format : Lvgl::ColorFormat = Lvgl::ColorFormat::Argb8888) : Nil
      draw_buf = LibLvgl.lv_snapshot_take(obj.raw, color_format.value)
      raise "Failed to snapshot active screen" if draw_buf.null?

      begin
        FileUtils.mkdir_p(File.dirname(path))
        save_draw_buffer_as_png(draw_buf, path)
      ensure
        LibLvgl.lv_draw_buf_destroy(draw_buf)
      end
    end

    def self.save_screen(path : String) : Nil
      display = LibLvgl.lv_display_get_default
      raise "No active LVGL display found" if display.null?

      draw_buf = LibLvgl.lv_display_get_buf_active(display)
      raise "Active LVGL display buffer is unavailable" if draw_buf.null?

      FileUtils.mkdir_p(File.dirname(path))
      save_draw_buffer_as_png(draw_buf, path)
    end

    private def self.save_draw_buffer_as_png(draw_buf : Pointer(LibLvgl::LvDrawBufT), path : String) : Nil
      draw_buf_data = draw_buf.as(UInt8*)
      header_word_1 = draw_buf_data.as(UInt32*)[0]
      header_word_2 = draw_buf_data.as(UInt32*)[1]
      header_word_3 = draw_buf_data.as(UInt32*)[2]

      color_format = (header_word_1 >> 8) & 0xFF
      unless color_format == Lvgl::ColorFormat::Argb8888.value || color_format == Lvgl::ColorFormat::Xrgb8888.value
        raise "Unsupported draw buffer color format #{color_format}; expected ARGB8888 or XRGB8888"
      end

      width = (header_word_2 & 0xFFFF).to_i
      height = (header_word_2 >> 16).to_i
      stride = (header_word_3 & 0xFFFF).to_i
      pixel_data_ptr = (draw_buf_data + 16).as(Pointer(UInt8*))[0]

      png_data = IO::Memory.new
      png_data.write(PNG_SIGNATURE)

      ihdr = IO::Memory.new
      ihdr.write_bytes(width.to_u32, IO::ByteFormat::BigEndian)
      ihdr.write_bytes(height.to_u32, IO::ByteFormat::BigEndian)
      ihdr.write_byte(8_u8) # bit depth
      ihdr.write_byte(6_u8) # color type RGBA
      ihdr.write_byte(0_u8) # compression
      ihdr.write_byte(0_u8) # filter
      ihdr.write_byte(0_u8) # interlace
      write_png_chunk(png_data, "IHDR", ihdr.to_slice)

      raw_scanlines = IO::Memory.new
      height.times do |y|
        raw_scanlines.write_byte(0_u8)
        row = pixel_data_ptr + (y * stride)
        width.times do |x|
          pixel = row + (x * 4)
          b = pixel[0]
          g = pixel[1]
          r = pixel[2]
          a = color_format == Lvgl::ColorFormat::Xrgb8888.value ? 255_u8 : pixel[3]
          raw_scanlines.write_byte(r)
          raw_scanlines.write_byte(g)
          raw_scanlines.write_byte(b)
          raw_scanlines.write_byte(a)
        end
      end

      compressed_scanlines = IO::Memory.new
      Compress::Zlib::Writer.open(compressed_scanlines) do |writer|
        writer.write(raw_scanlines.to_slice)
      end
      write_png_chunk(png_data, "IDAT", compressed_scanlines.to_slice)
      write_png_chunk(png_data, "IEND", Bytes.empty)

      File.write(path, png_data.to_slice)
    end

    private def self.write_png_chunk(io : IO, type : String, data : Bytes) : Nil
      io.write_bytes(data.size.to_u32, IO::ByteFormat::BigEndian)
      type_bytes = type.to_slice
      io.write(type_bytes)
      io.write(data)

      crc = Digest::CRC32.checksum(type_bytes)
      crc = Digest::CRC32.update(data, crc) unless data.empty?
      io.write_bytes(crc, IO::ByteFormat::BigEndian)
    end
  end
end
