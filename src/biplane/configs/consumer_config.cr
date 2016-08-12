module Biplane
  class ConsumerConfig
    include Config(self)
    include Mixins::Serialize
    include Mixins::Nested
    include Mixins::Timestamps

    child_key username
    as_nested acls, credentials

    YAML.mapping({
      username:    String,
      acls:        {type: Array(AclConfig), default: Array(AclConfig).new},
      credentials: {type: Array(CredentialConfig), default: Array(CredentialConfig).new},
    })

    def as_params
      {
        "username":   username,
        "created_at": pg_now,
      }
    end

    def acls
      ChildCollection.new(@acls, self)
    end

    def credentials
      ChildCollection.new(@credentials, self)
    end

    def serialize
      {
        "username":    username,
        "acls":        expand(acls),
        "credentials": expand(credentials),
      }
    end
  end
end
