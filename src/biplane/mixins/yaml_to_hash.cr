require "./parseable"

module Biplane::Mixins
  module YamlToHash
    include Parseable

    private def to_hash(item : YAML::Any)
      to_hash(item.raw)
    end

    private def to_hash(item : Terminals)
      case item
      when nil
        nil
      when .== "true"
        true
      when .== "false"
        false
      when .match /^\d+$/
        item.to_i64
      when .match /^\d+.\d+$/
        item.to_f64
      else
        item.to_s
      end
    end
  end
end
