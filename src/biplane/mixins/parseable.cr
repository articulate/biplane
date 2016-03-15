module Biplane::Mixins
  module Parseable
    alias Terminals = String | Bool | Int64 | Float64 | Nil
    alias Type = Terminals | Array(Type) | Hash(String, Type)

    alias Nested = Hash(String, Type) | Array(Type)

    # Don't allow nil values or enumerable types
    # that have no elements
    private def valid_value?(value)
      !value.is_a?(Nil) &&
        !(value.is_a?(Nested) && value.empty?)
    end

    private def to_hash(items : Array)
      # items.map { |v| to_hash(v) }.compact
      values = [] of Type

      items.each do |item|
        value = to_hash(item)
        values << value if valid_value?(value)
      end

      values
    end

    private def to_hash(items : Hash(K, V))
      return Hash(String, Type).new if items.empty?

      items.reduce(Hash(String, Type).new) do |memo, k, v|
        value = to_hash(v)

        memo[k.to_s] = value if valid_value?(value)
        memo
      end
    end
  end
end
