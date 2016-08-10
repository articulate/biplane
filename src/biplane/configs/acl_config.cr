module Biplane
  class AclConfig
    include Config(self)
    include Mixins::Nested
    include Mixins::NormalizeAttributes

    child_key group

    YAML.mapping({
      group: String,
    })

    def as_params
      normalize(serialize, {
        created_at: Time.now.epoch,
      })
    end

    def serialize
      {"group": group}
    end
  end
end
