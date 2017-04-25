require "../spec_helper"

module Biplane
  describe PluginConfig do
    plugin = yaml_fixture(PluginConfig)
    parent = yaml_fixture(ApiConfig)
    plugin.parent = parent

    it "can compare in reverse" do
      plugin.should eq json_fixture(Plugin)
    end

    it "knows collection path" do
      plugin.collection_route.should be_a(Route)
      plugin.collection_route.to_s.should eq "/apis/#{parent.name}/plugins"
    end

    # tricky because it requires the id from the API rather than the name from the config
    # will have to interpolate later
    it "knows instance path" do
      plugin.member_route.should be_a(Route)
      plugin.member_route.to_s.should eq "/apis/#{parent.name}/plugins/:id"
    end

    it "ignores empty values" do
      yaml = <<-YAML
        name: 'datadog'
        attributes:
          config:
            host: datadog
            timeout: 10000
            metrics:
              - request_count
              - latency
              - request_size
              - status_count
              - response_size
              - unique_users
              - request_per_user
            tags: {}
            port: 8125
      YAML

      empty_plugin = PluginConfig.from_yaml(yaml)
      config = empty_plugin.attributes["config"] as Hash

      config.keys.should_not contain("tags")
      # config["tags"].should eq Hash(String, PluginConfig::Type).new
    end

    it "can present config as params" do
      plugin.for_create.should eq({
        "name":   "acl",
        "config": {
          "whitelist": ["docs-auth", "google-auth"],
        },
        "created_at": "now",
      })
    end

    it "can read flattened config" do
      odd = PluginConfig.from_yaml(YAML.dump({
        name:       "what",
        attributes: {
          "config.whitelist": ["name", "only"],
        },
      }))

      odd.for_create.should eq({
        "name":   "what",
        "config": {
          "whitelist": ["name", "only"],
        },
        "created_at": "now",
      })
    end

    it "outputs epoch time for update" do
      plugin.for_update.should eq({
        "name":   "acl",
        "config": {
          "whitelist": ["docs-auth", "google-auth"],
        },
        "created_at": Time.now.epoch,
      })
    end
  end
end
