module Biplane
  class AclConfig
    include Config(self)
    include Mixins::Nested

    child_key group

    YAML.mapping({
      group: String,
    })

    def serialize
      {"group": group}
    end
  end
end
