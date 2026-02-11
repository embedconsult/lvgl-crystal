require "../spec_helper"

describe Lvgl::Event::Message do
  it "returns known code through #code?" do
    message = Lvgl::Event::Message.new(
      code_raw: Lvgl::Event::Code::Clicked.to_i,
      target_raw: Pointer(LibLvgl::LvObjT).null,
      current_target_raw: Pointer(LibLvgl::LvObjT).null
    )

    message.code?.should eq(Lvgl::Event::Code::Clicked)
  end

  it "returns nil for unsupported code values" do
    message = Lvgl::Event::Message.new(
      code_raw: 9999,
      target_raw: Pointer(LibLvgl::LvObjT).null,
      current_target_raw: Pointer(LibLvgl::LvObjT).null
    )

    message.code?.should be_nil
  end
end

describe Lvgl::Event do
  it "raises ArgumentError when capacity is negative" do
    object = Lvgl::Object.allocate

    expect_raises(ArgumentError, /capacity must be >= 0/) do
      Lvgl::Event.on(object, capacity: -1)
    end
  end
end

describe Lvgl::Object do
  it "raises ArgumentError for negative capacity via #on_event" do
    object = Lvgl::Object.allocate

    expect_raises(ArgumentError, /capacity must be >= 0/) do
      object.on_event(capacity: -1)
    end
  end
end
