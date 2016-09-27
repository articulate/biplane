module Biplane
  class AclConfig
    include Config(self)
    include Mixins::NormalizeAttributes
    include Mixins::Nested
    include Mixins::Timestamps

    child_key group

    YAML.mapping({
      group: String,
    })

    def for_create
      normalize(serialize, {created_at: pg_now})
    end

    def for_update
      normalize(for_create, {created_at: epoch_int})
    end

    def serialize
      {"group": group}
    end
  end
end
