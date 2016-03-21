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

    it "can present config as params" do
      plugin.as_params.should eq({
        "name":   "acl",
        "config": {
          "whitelist": ["docs-auth", "google-auth"],
        },
      })
    end

    it "can read flattened config" do
      odd = PluginConfig.from_yaml(YAML.dump({
        name:       "what",
        attributes: {
          "config.whitelist": ["name", "only"],
        },
      }))

      odd.as_params.should eq({
        "name":   "what",
        "config": {
          "whitelist": ["name", "only"],
        },
      })
    end
  end
end
