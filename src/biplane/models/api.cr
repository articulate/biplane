module Biplane
  class Api
    include Model(self)
    include Mixins::Serialize
    include Mixins::Nestable
    include Mixins::Nested

    diff_attrs name, request_path, strip_request_path, upstream_url, plugins
    child_collection(plugins, {name: name})
    child_key name

    JSON.mapping({
      created_at:         {type: Time, converter: Mixins::TimeFromMilli},
      id:                 String,
      name:               String,
      request_path:       String,
      strip_request_path: Bool,
      upstream_url:       String,
    })

    def serialize
      serial = Hash(String, Type).new

      {
        "name":       name,
        "attributes": {
          "request_path":       request_path,
          "strip_request_path": strip_request_path,
          "upstream_url":       upstream_url,
        },
        "plugins": plugins.serialize,
      }
    end
  end
end
