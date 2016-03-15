require "yaml"
require "./mixins/*"

module Biplane
  class ConfigManifest
    include Mixins::Serialize

    YAML.mapping({
      apis:      Array(ApiConfig),
      consumers: Array(ConsumerConfig),
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
  end
end
