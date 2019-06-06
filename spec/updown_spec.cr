require "./spec_helper"

describe Updown do
  it "can list checks, get by token with metrics, list downtimes" do
    # first time setup: create a check by hand (disabled is ok)
    checks = Updown::Check.all
    checks.size.should_not eq 0

    # refetch with metrics
    check = checks.first.get(metrics: true).not_nil!

    # list downtimes
    downtimes = Updown::Check.get_downtimes(check.token)
    downtimes.should_not be_nil

    # query metrics
    metrics = Updown::Check.get_metrics(check.token)
    metrics.should_not be_nil

    # returns nil on 404
    Updown::Check.get("nonexistent").should be_nil
  end

  it "creates checks" do
    Updown::Check.find_by_url("https://updown.io").should be_nil

    check = Updown::Check.new("https://updown.io")
    check.period = 300
    check.period.should eq 300
    check.save.should be_true

    # create and delete take quite a while to reflect in GET /api/checks
    sleep 30

    check.get
    check.period.should eq 300
  end

  it "updates checks" do
    check = Updown::Check.find_by_url("https://updown.io").not_nil!
    check.period.should eq 300
    check.period = 600
    check.save.should be_true
    check.get
    check.period.should eq 600
  end

  it "deletes checks" do
    check = Updown::Check.find_by_url("https://updown.io").not_nil!
    check.destroy.should be_true
  end
end
