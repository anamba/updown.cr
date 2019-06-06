module Updown
  class Check
    def initialize(@url, @period = 60, @apdex_t = 0.5, @enabled = true, @published = false)
      @token = ""
      @last_status = 0
      @down = false
      @uptime = 0.0
      @disabled_locations = [] of String
      @custom_headers = {} of String => String
    end

    JSON.mapping(
      token: {type: String, default: ""},
      url: String,
      alias: String?,
      last_status: Int32?,
      uptime: Float64,
      down: Bool,
      down_since: String?, # probably a datetime
      error: String?,
      period: Int32,
      apdex_t: Float64,
      string_match: String?,
      enabled: Bool,
      published: Bool,
      disabled_locations: Array(String),
      last_check_at: String?, # e.g. "2016-02-07T13:59:51Z",
      next_check_at: String?, # e.g. "2016-02-07T14:00:21Z",
      mute_until: String?,    # probably a datetime
      favicon_url: String?,
      custom_headers: Hash(String, String),
      http_verb: String?,
      http_body: String?,
      metrics: Metrics?,
      ssl: CheckSsl?
    )

    class CheckSsl
      JSON.mapping(
        tested_at: String, # e.g. "2016-02-07T13:30:08Z",
        valid: Bool,
        error: String?
      )
    end

    def self.all
      HTTP::Client.new(URI.parse(ENDPOINT)) do |client|
        response = client.get "/api/checks", headers: Updown.headers
        if response.success?
          Array(Check).from_json(response.body_io? || response.body)
        else
          raise Updown::Error.new(response)
        end
      end
    end

    def self.find_by_url(url)
      all.select { |c| c.url == "https://updown.io" }.first?
    end

    def self.get(token, metrics : Bool = false)
      HTTP::Client.new(URI.parse(ENDPOINT)) do |client|
        response = client.get "/api/checks/#{token}", headers: Updown.headers
        if response.success?
          Check.from_json(response.body_io? || response.body)
        elsif response.status_code == 404
          nil
        else
          raise Updown::Error.new(response)
        end
      end
    end

    def self.get_downtimes(token, page = 1)
      params = HTTP::Params{"page" => page.to_s}

      HTTP::Client.new(URI.parse(ENDPOINT)) do |client|
        response = client.get "/api/checks/#{token}/downtimes?#{params}", headers: Updown.headers
        if response.success?
          Array(Downtime).from_json(response.body_io? || response.body)
        elsif response.status_code == 404
          nil
        else
          raise Updown::Error.new(response)
        end
      end
    end

    def self.get_metrics(token, from : Time? = nil, to : Time? = nil)
      # def self.get_metrics(token, from : Time? = nil, to : Time? = nil, group : Symbol? = nil)
      # group should be either :time or :host

      params = HTTP::Params.new
      params["from"] = from if from
      params["to"] = to if to

      # group parameter not supported yet - not sure what the output looks like
      # params["group"] = group.to_s if group

      HTTP::Client.new(URI.parse(ENDPOINT)) do |client|
        response = client.get "/api/checks/#{token}/metrics?#{params}", headers: Updown.headers
        if response.success?
          Metrics.from_json(response.body_io? || response.body)
        elsif response.status_code == 404
          nil
        else
          raise Updown::Error.new(response)
        end
      end
    end

    # re-fetch an existing check (usually just to pull in metrics)
    def get(metrics : Bool = true)
      self.class.get(token, metrics)
    end

    def save
      params = HTTP::Params.new

      {% for param in @type.instance_vars.select { |p| Updown::VALID_ATTRIBUTES.map(&.id).includes?(p.id) } %}
        {% if param.type <= Array(String) %}
          unless @{{ param.id }}.nil?
            @{{ param.id }}.each do |val|
              params["{{ param.id }}[]"] = val
            end
          end
        {% elsif param.type <= Hash(String, String) %}
          unless @{{ param.id }}.nil?
            @{{ param.id }}.each do |k, v|
              params["{{ param.id }}[#{k}]"] = v
            end
          end
        {% elsif param.type <= String %}
          params["{{ param.id }}"] = @{{ param.id }} unless @{{ param.id }}.nil?
        {% else %}
          params["{{ param.id }}"] = @{{ param.id }}.to_s unless @{{ param.id }}.nil?
        {% end %}
      {% end %}

      if token == ""
        HTTP::Client.new(URI.parse(ENDPOINT)) do |client|
          response = client.post "/api/checks", form: params.to_s, headers: Updown.headers
          if response.success?
            initialize(JSON::PullParser.new(response.body_io? || response.body))
            true
          else
            raise Updown::Error.new(response)
          end
        end
      else
        HTTP::Client.new(URI.parse(ENDPOINT)) do |client|
          response = client.put "/api/checks/#{token}", form: params.to_s, headers: Updown.headers
          if response.success?
            initialize(JSON::PullParser.new(response.body_io? || response.body))
            true
          else
            raise Updown::Error.new(response)
          end
        end
      end
    end

    def destroy
      HTTP::Client.new(URI.parse(ENDPOINT)) do |client|
        response = client.delete "/api/checks/#{token}", headers: Updown.headers
        if response.success?
          true
        else
          raise Updown::Error.new(response)
        end
      end
    end
  end
end
