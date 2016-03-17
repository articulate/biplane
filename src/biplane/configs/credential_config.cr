module Biplane
  class CredentialConfig
    include Config(self)
    include Mixins::Nested

    child_key name
    property! plugin

    YAML.mapping({
      name:       String,
      attributes: {type: Hash(String, String), default: Hash(String, String).new},
    })

    # Specify this route with the name from the plugin
    def collection_route
      route(collection_key, {name: name})
    end

    def serialize
      {
        "name":       name,
        "attributes": attributes,
      }
    end
  end
end
