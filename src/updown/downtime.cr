module Updown
  class Downtime
    JSON.mapping(
      error: String,
      started_at: String, # e.g. "2015-12-03T09:14:19Z"
      ended_at: String,   # e.g. "2015-12-03T09:14:19Z"
      duration: Int32,
    )
  end
end
