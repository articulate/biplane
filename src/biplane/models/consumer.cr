module Biplane
  class Consumer
    include Model(self)
    include Mixins::Serialize
    include Mixins::Nestable
    include Mixins::Nested

    diff_attrs username, credentials, acls
    child_collection(acls, Acl)
    child_key username

    @credentials : ChildCollection(Credential)?

    property! credentials

    JSON.mapping({
      id:       String,
      username: String,
    })

    def cache_credentials(plugins)
      creds = plugins.map do |plugin|
        client.credentials({username: username, name: plugin.name}).each(&.plugin = plugin)
      end.flatten.uniq(&.name)

      @credentials = ChildCollection.new(creds, self)
    end

    def serialize
      {
        "username":    username,
        "credentials": credentials.serialize,
        "acls":        acls.serialize,
      }
    end
  end
end
