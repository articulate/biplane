module Biplane
  module Config(T)
    macro def member_key : Symbol
      :{{ @type.name.split("::").last.downcase.gsub(/config/, "") }}
    end

    macro def collection_key : Symbol
      :{{ @type.name.split("::").last.downcase.gsub(/config/, "s") }}
    end

    macro included
      def works_with
        {{ @type.name.gsub(/Config/, "").id }}
      end

      def ==(other : {{ @type.name.gsub(/Config/, "").id }})
        other == self
      end
    end

    private def route(route_key, params = {} of Symbol => String)
      params[parent.not_nil!.child_key] = parent.not_nil!.lookup_key unless parent.nil?

      Router.build(route_key, params)
    end

    def collection_route
      route(collection_key)
    end

    def member_route
      route(member_key, {child_key => lookup_key})
    end

    def inspect(io : IO)
      io << serialize.to_s
    end

    # overrides to allow for empty values
    private def valid_value?(value)
      !value.is_a?(Nil)
    end
  end
end
