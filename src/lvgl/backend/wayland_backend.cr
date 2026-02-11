require "./adapter"

module Lvgl::Backend
  # Placeholder for a future Wayland runtime profile.
  class WaylandBackend
    include Adapter

    def key : String
      "wayland"
    end

    def available? : Bool
      false
    end

    def unavailable_reason : String?
      "Wayland backend is a placeholder profile; not wired in this repository yet."
    end

    def setup! : Nil
      raise unavailable_reason || "Wayland backend unavailable"
    end

    def teardown! : Nil
    end
  end
end
