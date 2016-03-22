require "http/client"
require "json"

require "./model"
require "./models/*"

require "./config"
require "./configs/*"

module Biplane
  class KongClient
    include Mixins::NormalizeAttributes

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
    def initialize(host : String, port : Int = 8001, https : Bool = true)
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
        route = Router.build!({{name}}, args)

        response = @client.get(route.to_s) as HTTP::Client::Response

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

    def create(diff : Diff)
      create(diff.local as Config)
    end

    def create(config : Config)
      headers = HTTP::Headers.new
      headers.add("Content-Type", "application/json")

      response = @client.post(config.collection_route.to_s, headers, config.as_params.to_json) as HTTP::Client::Response
      @client.close # close immediately since we might make nested requests

      case response.status_code
      when 201
        puts "Created #{config.member_key.to_s} '#{config.lookup_key}'!".colorize(:green)
        config.nested.each { |c| create(c) } if config.nested.any?
      else
        raise APIError.new("Invalid API response (status code #{response.status_code}): #{response.body}")
      end
    end

    def destroy(diff : Diff)
      destroy(diff.remote as Model)
    end

    def destroy(object : Model)
      response = @client.delete(object.member_route.to_s) as HTTP::Client::Response

      case response.status_code
      when 204
        puts "#{object.member_key.to_s.capitalize} '#{object.lookup_key}' destroyed!".colorize(:red)
      else
        raise APIError.new("Invalid API response (status code #{response.status_code}): #{response.body}")
      end
    ensure
      @client.close
    end

    def update(diff : Diff)
      update(diff.local as Config, diff.remote as Model) if diff.changed?
    end

    def update(config : Config, object : Model)
      headers = HTTP::Headers.new
      headers.add("Content-Type", "application/json")

      params = normalize(config.as_params, {"id": object.id})
      response = @client.put(config.collection_route.to_s, headers, params.to_json) as HTTP::Client::Response

      case response.status_code
      when 200
        puts "Updated #{config.member_key.to_s} '#{config.lookup_key}'!".colorize(:yellow)
        Diff.new(config, object).print
      else
        raise APIError.new("Invalid API response (status code #{response.status_code}): #{response.body}")
      end
    ensure
      @client.close
    end

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
