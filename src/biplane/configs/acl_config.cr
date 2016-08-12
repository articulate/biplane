module Biplane
  class AclConfig
    include Config(self)
    include Mixins::Nested
    include Mixins::NormalizeAttributes
    include Mixins::Timestamps

    child_key group

    YAML.mapping({
      group: String,
    })

    def as_params
      normalize(serialize, {
        created_at: pg_now,
      })
    end

    def serialize
      {"group": group}
    end
  end
end
