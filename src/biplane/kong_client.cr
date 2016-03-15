require "http/client"
require "json"

require "./model"
require "./models/*"

module Biplane
  class KongClient
    class APIError < Exception; end

    class NotFound < Exception; end

    # Defines the endpoints and types associated with
    # :nodoc:
    ENDPOINTS = {
      apis:        Array(Api),
      api:         Api,
      plugins:     Array(Plugin),
      plugin:      Plugin,
      consumers:   Array(Consumer),
      consumer:    Consumer,
      credentials: Array(Credential),
      credential:  Credential,
      acls:        Array(Acl),
      acl:         Acl,
    }

    # Create a KongClient from a `host` with optional `port` (defaults to 8001)
    # and `ssl` config (defaults to `true`, meaning it uses the HTTPS scheme)
    #
    # `host` must be a plain hostname, no scheme or port info.
    def initialize(host : String, port = 8001 : Int, https = true : Bool)
      @client = HTTP::Client.new(host, port, ssl: https)
    end

    # Create a KongClient from a pre-configured HTTP client. This allows
    # you to configure your own HTTP client as you wish and then pass it directly
    # to KongClient. Must respond to `get(path)` with the root URL set
    def initialize(@client)
    end

    # Build methods for each of the endpoints to fetch data from the API
    #
    # ```
    # client = KongClient.new("kong.example.com")
    # client.apis
    # # => Array of Api objects
    #
    # client.api({api: "name of my api"})
    # # => Single Api object
    # ```
    #
    # Each method will raise a `NotFound` error if the API can't lookup
    # the requested resource.
    #
    # Parameters for each type are as follows. Most resources can lookup
    # all or singular resources. *\** denotes required when looking up both
    # plural and singular resources.
    #
    # - Api: `:name` - the name of the API requested
    # - Plugin: *`:name`, - the name of the API, `:id` - plugin id (uuid)
    # - Consumer: `:username` - consumer's username
    # - Credential: *`:username` - consumer's username, *`:id` - plugin id, `:name` - credential name
    # - Acl: *`:username` - consumer's username, `:id` - ACL id
    #
    {% for name, kind in ENDPOINTS %}
      def {{name.id}}(args = {} of Symbol => String)
        route = Router.build({{name}}, args)

        response = @client.get(route) as HTTP::Client::Response

        case response.status_code
        when 404
          not_found({{kind}})
        when 200
          build({{kind}}, JSON.parse(response.body).as_h)
        else
          raise APIError.new("Invalid API response (status code #{response.status_code})")
        end

      ensure
        @client.close
      end
    {% end %}

    # 404 when dealing with an Array-type class should return empty
    private def not_found(kind : Array.class)
      kind.new
    end

    # 404 when dealing with an instance should raise an error
    private def not_found(kind : Class)
      raise NotFound.new
    end

    private def build(kind : Array.class, body)
      return kind.new if body.empty?

      array = kind.from_json(body["data"].to_json)
      array.map(&.client = self)
      array
    end

    private def build(kind, body)
      # return nil unless body
      instance = kind.from_json(body.to_json)
      instance.client = self
      instance
    end
  end
end
