module Biplane
  class Plugin
    include Model(self)
    include Mixins::FlatFormatter
    include Mixins::JSONToHash
    include Mixins::Nested

    diff_attrs name, attributes
    child_key name

    getter! attributes

    JSON.mapping({
      created_at: {type: Time, converter: Mixins::TimeFromMilli},
      id:         String,
      api_id:     String,
      name:       String,
      config:     Hash(String, JSON::Any),
      enabled:    Bool,
    })

    def attributes
      @attributes ||= {"config": to_hash(@config) as Hash}
    end

    def serialize
      {
        "name"       => name,
        "attributes" => attributes,
      }
    end
  end
end
