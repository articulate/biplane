require "openssl/digest"

module Biplane
  class Credential
    include Model(self)
    include Mixins::Nested

    diff_attrs name, attributes
    transformed_diff_attr attributes, digest_password

    child_key name

    property! plugin

    JSON.mapping({
      consumer_id: String,
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

    private def digest_password(other_attrs)
      return other_attrs unless other_attrs.has_key?("password")

      password = other_attrs["password"]
      digest = OpenSSL::Digest.new("SHA1")
      digest << "#{password}#{consumer_id}"
      other_attrs["password"] = digest.to_s

      other_attrs
    end
  end
end
