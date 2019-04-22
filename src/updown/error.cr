module Updown
  class Error < Exception
    property status_code : Int32

    def initialize(response : HTTP::Client::Response)
      err = Updown::ErrorResponse.from_json(response.body_io? || response.body).error rescue response.body
      @status_code = response.status_code
      @message = "#{status_code}: #{err}"
    end
  end

  class ErrorResponse
    JSON.mapping(
      error: String,
    )
  end
end
