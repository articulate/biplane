module Biplane::Mixins
  module NormalizeAttributes
    include Parseable

    private def normalize(attrs : Hash, others = Hash(String, Type).new : Hash)
      res = attrs.reduce({} of String => Type) do |memo, k, v|
        normalize(memo, k.to_s, v)
      end

      others.reduce(res) { |memo, k, v| normalize(memo, k.to_s, v) }
    end

    private def normalize(memo, key, value)
      stretch_key(memo, key.split('.'), value)
    end

    private def stretch_key(attrs, keys : Array, value)
      key = keys.shift
      attrs[key] = keys.empty? ? ensure_type(value) : stretch_key({} of String => Type, keys, value)
      attrs
    end

    private def ensure_type(values : Hash)
      normalize(values)
    end

    private def ensure_type(values : Array)
      values.map { |v| v as Type }
    end

    private def ensure_type(value : String)
      (value.includes?(',') ? ensure_type(value.split(',')) : value) as Type
    end

    private def ensure_type(value : Bool | Int64 | Float64 | Nil)
      value as Type
    end
  end
end
