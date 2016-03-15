module Biplane
  class Acl
    include Model(self)
    include Mixins::Nested

    diff_attrs group
    child_key group

    JSON.mapping({
      consumer_id: String,
      created_at:  {type: Time, converter: Mixins::TimeFromMilli},
      id:          String,
      group:       String,
    })

    def serialize
      {"group": group}
    end
  end
end
