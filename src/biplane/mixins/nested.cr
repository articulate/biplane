module Biplane::Mixins
  module Nested
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
  end
end
