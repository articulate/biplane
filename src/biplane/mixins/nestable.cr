module Biplane::Mixins
  module Nestable
    macro child_collection(plural_type, lookup = {} of Symbol => String)
      # Lookup method for a child collection
      def {{plural_type}}
        @{{plural_type}} ||= begin
          children = client.{{plural_type}}({{lookup}})
          ChildCollection.new(children, self)
        end
      end
    end
  end
end
