module Biplane::Mixins
  module Nestable
    macro child_collection(plural_type)
      def {{plural_type}}
        @{{plural_type}} ||= begin
          children = client.{{plural_type}}({child_key => lookup_key})
          ChildCollection.new(children, self)
        end
      end
    end
  end
end
