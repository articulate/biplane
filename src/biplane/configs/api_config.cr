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
      format_uris attributes["uris"]
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

    private def format_uris(uris : YAML::Any)
      format_uris uris.raw
    end

    private def format_uris(uris : String)
      format_uris uris.split(",")
    end

    private def format_uris(uris : Array(YAML::Type))
      uris.map { |uri| drop_trailing_slash uri.to_s }
    end

    private def format_uris(uris : Nil)
      nil
    end

    private def format_uris(uris : Hash)
      format_uris uris.values
    end

    private def drop_trailing_slash(string : String)
      string.sub(/\/$/, "")
    end
  end
end
