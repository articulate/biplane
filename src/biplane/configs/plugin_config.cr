module Biplane
  class PluginConfig
    include Mixins::YamlToHash
    include Mixins::Nested
    include Mixins::NormalizeAttributes
    include Config(self)
    include Mixins::Timestamps

    child_key name
    getter! parsed_attrs

    YAML.mapping({
      name:       String,
      attributes: {type: Hash(String, YAML::Any), nilable: true},
    })

    def attributes
      @parsed_attrs ||= @attributes.nil? ? Hash(String, Type).new : normalize(to_hash(@attributes) as Hash)
    end

    def for_create
      normalize(attributes, {name: name})
    end

    def for_update
      normalize(for_create, {created_at: epoch_int})
    end

    def serialize
      serial = Hash(String, Type).new
      serial["name"] = name
      serial["attributes"] = attributes.not_nil! unless attributes.empty?

      serial
    end
  end
end
