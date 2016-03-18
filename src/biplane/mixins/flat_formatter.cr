module Biplane::Mixins
  module FlatFormatter
    alias ValueTypes = String | Bool | Int64 | Float64

    private def form_key(memo, key, item : ValueTypes)
      return memo if item.is_a?(String) && item.strip == ""

      memo[key] = item
      memo
    end

    private def form_key(memo, key, items : Array)
      return memo if items.empty?

      memo[key] = items.join(",")
      memo
    end

    private def form_key(memo, key, items : Hash)
      return memo if items.empty?

      items.each do |k, v|
        next if v.nil?
        form_key(memo, "#{key}.#{k}", v).not_nil!
      end

      memo
    end

    private def flatten(items)
      (items as Hash).reduce({} of String => ValueTypes) do |memo, k, v|
        form_key(memo, k.to_s, v)
      end
    end

    private def flatten(base_key, item)
      form_key({} of String => ValueTypes, base_key, item)
    end

    private def form_key(memo, key, item : Nil)
      raise "Invalid config parameter: #{key}"
    end
  end
end
