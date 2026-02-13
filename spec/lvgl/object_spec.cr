require "../spec_helper"

describe Lvgl::Object do
  it "tracks wrapper instance count" do
    Lvgl::Object.instance_count.should be >= 0
  end

  it "returns nil from .wrap for null pointers" do
    Lvgl::Object.wrap(Pointer(LibLvgl::LvObjT).null).should be_nil
  end
end

describe "Lvgl::Object runtime behavior" do
  it "creates parent/child wrappers and exposes pointer helpers" do
    Lvgl::SpecSupport::Harness.with_runtime do
      parent = Lvgl::Object.new(nil)
      child = Lvgl::Object.new(parent)

      child.parent.should eq(parent)
      child.raw.should eq(child.to_unsafe)
      child.raw.null?.should be_false
    end
  end

  it "supports basic object operations and child lookup" do
    Lvgl::SpecSupport::Harness.with_runtime do
      root = Lvgl::Object.new(nil)
      first_child = Lvgl::Object.new(root)
      _second_child = Lvgl::Object.new(root)

      root.set_size(120, 48)
      root.size = {240, 96}
      root.set_pos(5, 7)
      root.pos = {8, 9}
      root.center
      root.align(Lvgl::Align::Center)
      root.align(Lvgl::Align::Center, offset: {3, 4})
      root.set_style_bg_color(Lvgl::Color.hex(0x336699), selector: Lvgl::Part::Main)
      root.set_style_text_color(Lvgl::Color.hex(0xEEEEEE), selector: Lvgl::Part::Main)

      root[0].raw.should eq(first_child.raw)
      expect_raises(IndexError) { root[99] }
    end
  end

  it "wraps Lvgl::Object.screen_active when runtime is available" do
    unless Lvgl::SpecSupport::Harness.runtime_ready?
      puts "Skipping runtime-dependent screen_active check: #{Lvgl::SpecSupport::Harness.runtime_skip_reason}"
      next
    end

    begin
      screen = Lvgl::Object.screen_active
      screen.parent.should be_nil
      screen.raw.null?.should be_false
    ensure
      Lvgl::SpecSupport::Harness.safe_cleanup
    end
  end
end
