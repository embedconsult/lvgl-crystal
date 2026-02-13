require "./adapter"
require "./headless_test_backend"

module Lvgl::Backend
  # Wayland backend profile.
  #
  # This repository currently relies on the LVGL test-module runtime path for
  # deterministic setup in CI and local Debian environments. Until native
  # Wayland driver symbols are part of the linked shared library, this adapter
  # routes setup/teardown through the same proven headless bring-up path.
  #
  # This keeps `LVGL_BACKEND=wayland` wired into the runtime lifecycle today,
  # while preserving a clear upgrade path to native Wayland windowing in a
  # future change.
  class WaylandBackend
    include Adapter

    @delegate = HeadlessTestBackend.new

    def key : String
      "wayland"
    end

    def available? : Bool
      @delegate.available?
    end

    def unavailable_reason : String?
      return nil if available?

      "Wayland backend currently uses the LVGL headless test runtime path; run `./scripts/build_lvgl_headless_test.sh` to rebuild liblvgl with required test symbols."
    end

    def setup! : Nil
      raise unavailable_reason || "Wayland backend unavailable" unless available?

      @delegate.setup!
    end

    def teardown! : Nil
      @delegate.teardown!
    end
  end
end
