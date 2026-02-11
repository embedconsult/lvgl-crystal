module Lvgl::Backend
  # Contract for display/input backend adapters used by specs and examples.
  module Adapter
    abstract def key : String
    abstract def available? : Bool
    abstract def unavailable_reason : String?
    abstract def setup! : Nil
    abstract def teardown! : Nil
  end
end
