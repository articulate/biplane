module Biplane
  class CredentialConfig
    include Config(self)
    include Mixins::Nested

    child_key name

    YAML.mapping({
      name:       String,
      attributes: {type: Hash(String, String), default: Hash(String, String).new},
    })

    def serialize
      {
        "name":       name,
        "attributes": attributes,
      }
    end
  end
end
