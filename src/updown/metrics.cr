module Updown
  class Metrics
    JSON.mapping(
      apdex: Float64?,
      requests: MetricsRequests?,
      timings: MetricsTimings?,
    )

    class MetricsRequests
      JSON.mapping(
        samples: Int32,
        failures: Int32,
        satisfied: Int32,
        tolerated: Int32,
        by_response_time: MetricsRequestsByResponseTime,
      )
    end

    class MetricsRequestsByResponseTime
      JSON.mapping(
        under125: Int32,
        under250: Int32,
        under500: Int32,
        under1000: Int32,
        under2000: Int32,
        under4000: Int32,
      )
    end

    class MetricsTimings
      JSON.mapping(
        redirect: Int32,
        namelookup: Int32,
        connection: Int32,
        handshake: Int32,
        response: Int32,
        total: Int32,
      )
    end
  end
end
