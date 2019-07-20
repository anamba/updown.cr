require "http"
require "json"
require "./updown/check"
require "./updown/downtime"
require "./updown/error"
require "./updown/metrics"
require "./updown/node"

module Updown
  VERSION  = "0.2.1"
  ENDPOINT = "https://updown.io"

  # Valid attributes on PUT and POST https://updown.io/api
  VALID_ATTRIBUTES = %i[url period apdex_t enabled published alias string_match mute_until http_verb http_body disabled_locations custom_headers]

  class Settings
    property api_key : String = ENV["UPDOWN_API_KEY"]? || ""
  end

  def self.settings
    @@settings ||= Settings.new
  end

  def self.headers
    HTTP::Headers{"X-API-KEY" => settings.api_key}
  end
end
