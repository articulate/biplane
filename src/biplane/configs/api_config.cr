module Biplane
  class ApiConfig
    include Config(self)
    include Mixins::Serialize
    include Mixins::YamlToHash
    include Mixins::Nested

    child_key name
    as_nested plugins

    YAML.mapping({
      name:       String,
      attributes: Hash(String, YAML::Any),
      plugins:    {type: Array(PluginConfig), default: Array(PluginConfig).new},
    })

    def request_path
      drop_trailing_slash attributes["request_path"].to_s
    end

    def strip_request_path
      attributes["strip_request_path"] == "true"
    end

    def upstream_url
      attributes["upstream_url"].to_s
    end

    def plugins
      ChildCollection.new(@plugins, self)
    end

    def as_params
      {
        "name":               name,
        "request_path":       request_path,
        "strip_request_path": strip_request_path,
        "upstream_url":       upstream_url,
      }
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
