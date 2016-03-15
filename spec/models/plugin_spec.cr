require "../spec_helper"

module Biplane
  describe Plugin do
    it "can serialize" do
      plugin = json_fixture(Plugin)
      plugin.serialize.should eq({
        "name"       => "acl",
        "attributes" => {
          "config" => {
            "whitelist" => ["docs-auth", "google-auth"],
          },
        },
      })
    end

    it "ignores empty things" do
      json = <<-JSON
      {
        "id": "123-456-789",
        "api_id": "987-654-321",
        "enabled": true,
        "created_at": 1456856994000,
        "name": "request-transformer",
        "config": {
          "replace": {
            "body": {},
            "querystring": {},
            "headers": {}
          },
          "add": {
            "querystring": {},
            "body": {},
            "headers": [
              "x-kong-prefix:content-pass",
              "x-kong-host:docker|8000"
            ]
          },
          "remove": {
            "body": {},
            "querystring": {},
            "headers": {}
          },
          "append": {
            "body": {},
            "querystring": {},
            "headers": {}
          }
        }
      }
      JSON

      plugin = Plugin.from_json(json)
      plugin.serialize.should eq({
        "name":       "request-transformer",
        "attributes": {
          "config": {
            "add": {
              "headers": [
                "x-kong-prefix:content-pass",
                "x-kong-host:docker|8000",
              ],
            },
          },
        },
      })
    end

    describe "comparison" do
      plugin = json_fixture(Plugin)
      cfg = yaml_fixture(PluginConfig)

      it "can check equality" do
        plugin.should eq(cfg)
      end

      it "fails if not equal" do
        new_cfg = yaml_fixture(PluginConfig)
        new_cfg.name = "face"

        plugin.should_not eq(new_cfg)
      end

      it "can diff with missing" do
        new_cfg = yaml_fixture(PluginConfig)
        new_cfg.attributes = nil

        plugin.diff(new_cfg).should eq({"attributes": {"config": Diff.new(nil, plugin.attributes["config"])}})
      end
    end
  end
end
