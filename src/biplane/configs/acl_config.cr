module Biplane
  class AclConfig
    include Config(self)
    include Mixins::Nested

    child_key group

    YAML.mapping({
      group: String,
    })

    def as_params
      serialize
    end

    def serialize
      {"group": group}
    end
  end
end
