module Biplane::Mixins
  module Nestable
    macro child_collection(plural_type, key, lookup = {} of Symbol => String)
      def {{plural_type}}
        @{{plural_type}} ||= ChildCollection.new("{{key}}", client.{{plural_type}}({{lookup}}))
      end
    end
  end
end
