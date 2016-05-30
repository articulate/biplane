module Biplane::Mixins
  module Nested
    @parent : Model::Types? | Config::Types?

    property parent

    macro child_key(key)
      # Lookup method for the key used to find self in a collection
      def self.child_key
        :{{key.id}}
      end

      def child_key
        self.class.child_key
      end

      # Returns the actual key value
      def lookup_key
        {{key}}
      end
    end

    # ensure any class mixing this in responds to nested
    def nested
      [] of self
    end

    macro as_nested(*collections)
      def nested
        [
        {% for collection in collections %}
          {{collection}}.collection,
        {% end %}
        ].flatten
      end
    end
  end
end
