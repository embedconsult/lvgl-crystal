require "compiler/crystal/loader"

module Lvgl::SpecSupport
  module Harness
    @@backend = Lvgl::Backend.from_env
    @@setup_attempted = false
    @@runtime_ready = false
    @@runtime_skip_reason = ""

    def self.backend : Lvgl::Backend::Adapter
      @@backend
    end

    def self.runtime_prerequisites_available? : Bool
      lvgl_library_available? && @@backend.available?
    end

    def self.runtime_prerequisite_reason : String
      return lvgl_library_unavailable_reason unless lvgl_library_available?

      @@backend.unavailable_reason || "backend '#{@@backend.key}' is unavailable"
    end

    def self.runtime_ready? : Bool
      ensure_setup
      @@runtime_ready
    end

    def self.runtime_skip_reason : String
      ensure_setup
      @@runtime_skip_reason
    end

    def self.with_runtime(&)
      return unless runtime_ready?

      begin
        yield
      ensure
        safe_cleanup
      end
    end

    def self.safe_cleanup : Nil
      begin
        @@backend.teardown! if @@setup_attempted
      rescue
      end

      begin
        Lvgl::Runtime.shutdown if Lvgl::Runtime.initialized?
      rescue
      end

      @@setup_attempted = false
      @@runtime_ready = false
      @@runtime_skip_reason = ""
    end

    private def self.ensure_setup : Nil
      return if @@setup_attempted

      @@setup_attempted = true

      unless runtime_prerequisites_available?
        @@runtime_ready = false
        @@runtime_skip_reason = runtime_prerequisite_reason
        return
      end

      begin
        @@backend.setup!
        @@runtime_ready = true
      rescue ex
        @@runtime_ready = false
        @@runtime_skip_reason = "backend '#{@@backend.key}' setup failed: #{ex.message}"
      end
    end

    private def self.lvgl_library_available? : Bool
      loader = ::Crystal::Loader.new([lvgl_library_dir])
      return false unless loader.load_file?(lvgl_library_path)

      REQUIRED_LVGL_SYMBOLS.all? { |symbol| loader.find_symbol?(symbol) }
    rescue
      false
    end

    private def self.lvgl_library_unavailable_reason : String
      "LVGL shared library missing required symbols at #{lvgl_library_path}"
    end

    private REQUIRED_LVGL_SYMBOLS = {
      "lv_init",
      "lv_deinit",
      "lv_screen_active",
      "lv_obj_create",
    }

    private def self.lvgl_library_path : String
      Path[__DIR__, "../../lib/lvgl/build/crystal/liblvgl.so"].expand.to_s
    end

    private def self.lvgl_library_dir : String
      File.dirname(lvgl_library_path)
    end

    at_exit do
      safe_cleanup
    end
  end
end
