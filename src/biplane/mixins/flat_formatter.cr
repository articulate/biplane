module Biplane::Mixins
  module FlatFormatter
    private def form_key(key, item : String | Bool | Int64 | Float64)
      "#{key}=#{item}"
    end

    private def form_key(key, items : Array)
      "#{key}=#{items.join(",")}"
    end

    private def form_key(key, items : Hash)
      return if items.empty?

      items.map do |k, v|
        result = form_key(k, v)
        "#{key}.#{result}" unless result.nil?
      end.compact
    end

    private def form_key(key, item : Nil)
      raise "Invalid config parameter: #{key}"
    end

    private def form_key(key, item : JSON::Any)
      form_key(key, item.raw)
    end
  end
end
