module Updown
  class Error < Exception
    def initialize(response : HTTP::Client::Response)
      err = Updown::ErrorResponse.from_json(response.body_io? || response.body).error rescue response.body
      @message = "#{response.status_code}: #{err}"
    end
  end

  class ErrorResponse
    JSON.mapping(
      error: String,
    )
  end
end
