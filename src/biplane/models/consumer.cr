module Biplane
  class Consumer
    include Model(self)
    include Mixins::Serialize
    include Mixins::Nestable
    include Mixins::Nested

    diff_attrs username, credentials, acls
    child_collection(acls, {username: username})
    child_key username

    property! credentials

    JSON.mapping({
      created_at: {type: Time, converter: Mixins::TimeFromMilli},
      id:         String,
      username:   String,
    })

    def cache_credentials(plugins)
      creds = plugins.map do |plugin|
        client.credentials({username: username, name: plugin.name}).each(&.plugin = plugin)
      end.flatten.uniq(&.name)

      @credentials = ChildCollection.new(creds)
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
