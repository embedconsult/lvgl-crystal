require "./adapter"

module Lvgl::Backend
  # Placeholder for a future SDL runtime profile.
  class SdlBackend
    include Adapter

    def key : String
      "sdl"
    end

    def available? : Bool
      false
    end

    def unavailable_reason : String?
      "SDL backend is a placeholder profile; not wired in this repository yet."
    end

    def setup! : Nil
      raise unavailable_reason || "SDL backend unavailable"
    end

    def teardown! : Nil
    end
  end
end
