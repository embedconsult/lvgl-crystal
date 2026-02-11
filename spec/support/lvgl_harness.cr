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
      @@backend.available?
    end

    def self.runtime_prerequisite_reason : String
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

    private def self.ensure_setup : Nil
      return if @@setup_attempted

      @@setup_attempted = true

      unless @@backend.available?
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

    at_exit do
      if @@setup_attempted && @@runtime_ready
        @@backend.teardown!
      end

      Lvgl::Runtime.shutdown if Lvgl::Runtime.initialized?
    end
  end
end
