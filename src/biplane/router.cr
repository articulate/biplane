module Biplane
  module Router
    KEY    = /(:\w+)/
    ROUTES = {
      apis:        "/apis",
      api:         "/apis/:name",
      plugins:     "/apis/:name/plugins",
      plugin:      "/apis/:name/plugins/:id",
      consumers:   "/consumers",
      consumer:    "/consumers/:username",
      credentials: "/consumers/:username/:name",
      credential:  "/consumers/:username/:name/:id",
      acls:        "/consumers/:username/acls",
      acl:         "/consumers/:username/acls/:id",
    }

    class MissingParam < Exception; end

    def self.build(resource : Symbol, args = {} of Symbol => String)
      interpolate(ROUTES[resource], args)
    end

    private def self.interpolate(base, args)
      required = base.scan(KEY).map(&.[1].sub(':', ""))
      diff = (required - args.keys.map(&.to_s))

      raise MissingParam.new("Missing arguments #{diff.join(", ")}.") unless diff.empty?

      args.each do |k, v|
        base = base.gsub(":#{k}", v)
      end

      base
    end
  end
end
