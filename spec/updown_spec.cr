require "./spec_helper"

describe Updown do
  it "can list checks, get by token with metrics, list downtimes" do
    checks = Updown::Check.all
    checks.size.should_not eq 0

    # refetch with metrics
    check = checks.first.get(metrics: true)
    check.should_not be_nil

    # list downtimes
    downtimes = Updown::Check.get_downtimes(check.token)
    downtimes.should_not be_nil

    # query metrics
    metrics = Updown::Check.get_metrics(check.token)
    metrics.should_not be_nil

    expect_raises(Updown::Error) { Updown::Check.get("nonexistent") }
  end

  it "creates checks" do
    check = Updown::Check.new("https://updown.io")
    check.period = 300
    check.period.should eq 300
    check.save.should be_true
    sleep 1 # takes some time
    check.period.should eq 300
  end

  it "updates checks" do
    checks = Updown::Check.all
    check = checks.select { |c| c.url = "https://updown.io" }.first
    check.period.should eq 300
    check.period = 600
    check.save.should be_true
    sleep 1 # takes some time
    check.period.should eq 600
  end

  it "deletes checks" do
    checks = Updown::Check.all
    check = checks.select { |c| c.url = "https://updown.io" }.first
    check.destroy.should be_true
  end
end
