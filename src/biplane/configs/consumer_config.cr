module Biplane
  class ConsumerConfig
    include Config(self)
    include Mixins::Serialize
    include Mixins::Nested

    child_key username

    YAML.mapping({
      username:    String,
      acls:        Array(AclConfig),
      credentials: Array(CredentialConfig),
    })

    def as_params
      {"username": username}
    end

    def acls
      ChildCollection.new(@acls)
    end

    def credentials
      ChildCollection.new(@credentials)
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
