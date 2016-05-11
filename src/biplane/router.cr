require "./route"

module Biplane
  module Router
    ROUTES = {
      "apis"        => "/apis",
      "api"         => "/apis/:name",
      "plugins"     => "/apis/:name/plugins",
      "plugin"      => "/apis/:name/plugins/:id",
      "consumers"   => "/consumers",
      "consumer"    => "/consumers/:username",
      "credentials" => "/consumers/:username/:name",
      "credential"  => "/consumers/:username/:name/:id",
      "acls"        => "/consumers/:username/acls",
      "acl"         => "/consumers/:username/acls/:id",
    }

    def self.build(resource : String, args = {} of Symbol => String)
      Route.new(ROUTES[resource], args)
    end

    def self.build!(resource : String, args = {} of Symbol => String)
      Route.new(ROUTES[resource], args).validate!
    end
  end
end
