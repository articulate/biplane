require "yaml"
require "./mixins/*"

module Biplane
  class ConfigManifest
    include Mixins::Serialize

    YAML.mapping({
      apis:      {type: Array(ApiConfig), default: [] of ApiConfig},
      consumers: {type: Array(ConsumerConfig), default: [] of ConsumerConfig},
    })

    def_serialize apis, consumers

    def self.new(filepath : String)
      new File.new(filepath)
    end

    def self.new(file : File)
      from_yaml(file.gets_to_end)
    ensure
      file.close
    end

    def apis
      ChildCollection.new(@apis)
    end

    def consumers
      ChildCollection.new(@consumers)
    end
  end
end
