module Biplane::Mixins
  module Nested
    macro child_key(key)
      def lookup_key
        {{key}}
      end
    end
  end
end
