require "../spec_helper"

describe Lvgl::Scheduler do
  it "rejects invalid constructor arguments" do
    expect_raises(ArgumentError, /tick_period_ms must be > 0/) do
      Lvgl::Scheduler.new(tick_period_ms: Lvgl::Scheduler::ZERO_MS)
    end

    expect_raises(ArgumentError, /max_sleep_ms must be > 0/) do
      Lvgl::Scheduler.new(max_sleep_ms: Lvgl::Scheduler::ZERO_MS)
    end

    expect_raises(ArgumentError, /queue_capacity must be >= 0/) do
      Lvgl::Scheduler.new(queue_capacity: -1)
    end
  end

  it "runs scheduled work on drain" do
    scheduler = Lvgl::Scheduler.new(queue_capacity: 1)
    value = 0

    scheduler.schedule { value = 7 }

    scheduler.drain_scheduled_work.should eq(1)
    value.should eq(7)
  end

  it "closes queue and rejects new work" do
    scheduler = Lvgl::Scheduler.new

    scheduler.close
    scheduler.closed?.should be_true

    expect_raises(Exception, /scheduler is closed/) do
      scheduler.schedule { }
    end
  end
end
