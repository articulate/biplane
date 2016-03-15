module Biplane::Mixins
  module Serialize
    macro def_serialize(*attrs)
      def serialize
        {
        {% for attr in attrs %}
          "{{attr}}": expand({{attr}}),
        {% end %}
        }
      end
    end

    private def expand(attr)
      attr.map &.serialize
    end
  end
end
