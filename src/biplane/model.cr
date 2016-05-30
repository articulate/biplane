require "json"
require "./mixins/*"

module Biplane
  module Model(T)
    include Mixins::Parseable

    @client : KongClient?

    property! client

    def inspect(io : IO)
      io << serialize.to_s
    end

    macro def member_key : String
      {{ @type.name.split("::").last.downcase }}
    end

    def member_route
      params = {child_key => lookup_key, :id => id}
      params[parent.not_nil!.child_key] = parent.not_nil!.lookup_key unless parent.nil?

      Router.build(member_key, params)
    end

    # Special case methods where we need to transform the "other"
    # value with knowledge of the "self" value being compared against
    macro transformed_diff_attr(attr, transformer)
      def {{attr}}_compare(other : {{T}}Config)
        transformed = {{transformer}}(other.{{attr}})
        compare({{attr}}, transformed, other)
      end
    end

    macro diff_attrs(*attrs)
      # Build compare methods for each vanilla property
      {% for attr in attrs %}
        def {{attr}}_compare(other : {{T}}Config)
          compare({{attr}}, other.{{attr}}, other)
        end
      {% end %}

      def diff(other : {{T}}Config)
        {
        {% for attr in attrs %}
          "{{attr}}": {{attr}}_compare(other),
        {% end %}
        }.reject {|k, v| v.nil? }
      end

      def ==(other : {{T}}Config)
        diff(other).empty?
      end
    end

    def diff(other : Nil)
      Diff.new(nil, self)
    end

    def compare(server : ChildCollection, local : ChildCollection | Array, other : Config)
      server.diff(local) unless server == local
    end

    # diffing nested info
    def compare(server : Hash, local : Hash, other : Config)
      res = server.reduce(Hash(String, Diff).new) do |memo, k, v|
        lhs = local.fetch(k, nil)
        memo[k] = Diff.new(lhs, v, [other, self]) unless v == lhs
        memo
      end

      res.empty? ? nil : res
    end

    def compare(server, local, other : Config)
      Diff.new(local, server, [other, self]) unless server == local
    end
  end
end
