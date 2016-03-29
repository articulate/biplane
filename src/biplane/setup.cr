require "json"

module Biplane
  class Setup
    include Mixins::JSONToHash

    TYPE_MAP = {
      string: String,
      int:    Int64 | Int32,
      float:  Float64,
      bool:   Bool,
    }

    macro define_getters
      {% for type, klass in TYPE_MAP %}
        def get_{{type.id}}(key, default : {{klass}} = nil)
          get(key, default) as {{klass}}
        end
      {% end %}
    end

    define_getters

    def initialize(file : File)
      @file = file
      @path = file.path
      @values = {} of String => Type

      config
      sync
    end

    def self.new(path : String = "./.biplane")
      File.new(path, "w") unless File.exists?(path)
      new File.open(path, "r")
    end

    def config
      return @values unless @values.empty?

      contents = @file.gets_to_end
      @values = to_hash(JSON.parse(contents)) as Hash unless contents.empty?

      @values
    end

    def show
      @values.map { |k, v| "#{k}=#{v}" }.join("\n")
    end

    def gets(*keys)
      gets(keys.to_a)
    end

    def gets(keys : Array)
      keys.map { |k| get(k) }.to_a
    end

    def get(key, default = nil)
      config.fetch(key.to_s, default) as Terminals
    end

    def get(key, default = nil, &block)
      value = get(key, default)
      value.nil? ? set(key, yield) : value
    end

    def set(values : Array)
      values.each do |kv|
        key, value = kv.split("=")
        set(key, value)
      end
    end

    def set(key, value)
      @values[key.to_s] = value
      sync

      value
    end

    def set(key, &block)
      set(key, yield)
    end

    def set?(key)
      !get(key).nil?
    end

    def remove(*keys)
      keys.each { |k| @values.delete(k) }
      sync
    end

    private def sync
      File.write @path, @values.to_pretty_json
    end
  end
end
