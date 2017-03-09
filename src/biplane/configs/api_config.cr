module Biplane
  class ApiConfig
    include Mixins::Serialize
    include Mixins::YamlToHash
    include Config(self)
    include Mixins::Nested
    include Mixins::Timestamps

    child_key name
    as_nested plugins

    YAML.mapping({
      name:       String,
      attributes: Hash(String, YAML::Any),
      plugins:    {type: Array(PluginConfig), default: Array(PluginConfig).new},
    })

    def uris
      drop_trailing_slash attributes["uris"].to_s
    end

    def strip_uri
      attributes["strip_uri"] == "true"
    end

    def upstream_url
      attributes["upstream_url"].to_s
    end

    def plugins
      ChildCollection.new(@plugins, self)
    end

    def for_create
      {
        "name":         name,
        "uris":         uris,
        "strip_uri":    strip_uri,
        "upstream_url": upstream_url,
        "created_at":   pg_now,
      }
    end

    def for_update
      for_create.merge({"created_at": epoch_int})
    end

    def serialize
      {
        "name":       name,
        "attributes": to_hash(attributes),
        "plugins":    expand(plugins),
      }
    end

    private def drop_trailing_slash(string : String)
      string.sub(/\/$/, "")
    end
  end
end
