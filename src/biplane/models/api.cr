module Biplane
  class Api
    include Model(self)
    include Mixins::Serialize
    include Mixins::Nestable
    include Mixins::Nested

    diff_attrs name, uris, strip_uri, upstream_url, plugins
    child_collection(plugins)
    child_key name

    JSON.mapping({
      id:           String,
      name:         String,
      uris:         String,
      strip_uri:    Bool,
      upstream_url: String,
    })

    def serialize
      serial = Hash(String, Type).new

      {
        "name":       name,
        "attributes": {
          "uris":         uris,
          "strip_uri":    strip_uri,
          "upstream_url": upstream_url,
        },
        "plugins": plugins.serialize,
      }
    end
  end
end
