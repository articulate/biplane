require "./parseable"

module Biplane::Mixins
  module JSONToHash
    include Parseable

    private def to_hash(item : JSON::Any)
      to_hash(item.raw)
    end

    private def to_hash(item : Terminals)
      item
    end
  end
end
