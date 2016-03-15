module Biplane
  class Credential
    include Model(self)
    include Mixins::Nested

    diff_attrs name, attributes
    child_key name

    property! plugin

    JSON.mapping({
      consumer_id: String,
      created_at:  {type: Time, converter: Mixins::TimeFromMilli},
      id:          String,
      key:         {type: String, nilable: true},
      secret:      {type: String, nilable: true},
      username:    {type: String, nilable: true},
      password:    {type: String, nilable: true},
    })

    macro def attributes : Hash(String, String)
      attrs = Hash(String, String).new

      {% for key in %w(key secret username password) %}
        attrs[{{key}}] = {{key.id}}.to_s unless {{key.id}}.nil?
      {% end %}

      attrs
    end

    def name
      plugin.name
    end

    def serialize
      {
        "name":       name,
        "attributes": attributes,
      }
    end
  end
end
