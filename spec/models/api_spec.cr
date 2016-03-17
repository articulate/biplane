require "../spec_helper"

module Biplane
  describe Api do
    api = json_fixture(Api)
    cfg = yaml_fixture(ApiConfig)

    fake_client = double
    fake_client.stub(:close)
    plugin_fixture = {
      "data": [
        {
          "api_id": "fe67b76c-e586-48c8-b7cd-1386f9401cb5",
          "config": {
            "whitelist": [
              "google-auth",
            ],
          },
          "created_at": 1456414790000,
          "enabled":    true,
          "id":         "f65bbbc0-6e65-479c-acc6-444d5b2a4703",
          "name":       "acl",
        },
        {
          "api_id": "fe67b76c-e586-48c8-b7cd-1386f9401cb5",
          "config": {
            "key_claim_name":   "aud",
            "secret_is_base64": true,
            "uri_param_names":  [
              "jwt",
            ],
          },
          "created_at": 1456414790000,
          "enabled":    true,
          "id":         "449b2037-8ec3-4efd-bfec-eaa1c7cc00eb",
          "name":       "jwt",
        },
      ],
      "total": 2,
    }

    response = build_response(plugin_fixture)
    fake_client.stub(:get).with("/apis/library_public_api/plugins").and_return(response)
    api.client = KongClient.new(fake_client)

    it "knows member route" do
      api.member_route.to_s.should eq "/apis/#{api.name}"
    end

    it "can compare with config objects" do
      api.should eq(cfg)
    end

    describe "when different" do
      api.strip_request_path = false

      it "is not equal" do
        api.should_not eq(cfg)
      end

      it "can return a diff" do
        api.diff(cfg).should eq({"strip_request_path" => Diff.new(true, false)})
      end
    end

    describe "child resources" do
      it "can fetch plugins" do
        plugins = api.plugins

        plugins.size.should eq(2)
        plugins.is_a?(ChildCollection(Plugin)).should be_true
      end

      it "can return diffs" do
        # changed name (in effect dropping one and adding a new one)
        # modifed an existing
        #
        api = json_fixture(Api)
        api.strip_request_path = false

        diff_fixture = {
          "data": [
            {
              "api_id":     "fe67b76c-e586-48c8-b7cd-1386f9401cb5",
              "config":     {} of String => String,
              "created_at": 1456414790000,
              "enabled":    true,
              "id":         "f65bbbc0-6e65-479c-acc6-444d5b2a4703",
              "name":       "acl",
            },
            {
              "api_id":     "fe67b76c-e586-48c8-b7cd-1386f9401cb5",
              "config":     {} of String => String,
              "created_at": 1456414790000,
              "enabled":    true,
              "id":         "449b2037-8ec3-4efd-bfec-eaa1c7cc00eb",
              "name":       "jit",
            },
          ],
          "total": 2,
        }

        fake_client = double
        fake_client.stub(:get).with("/apis/library_public_api/plugins").and_return(build_response(diff_fixture))
        fake_client.stub(:close)

        api.client = KongClient.new(fake_client)

        api.diff(cfg).should eq({
          "strip_request_path": Diff.new(true, false),
          "plugins":            {
            # modified config
            "acl": {"attributes": {
              "config": Diff.new({"whitelist": ["google-auth"]}, {} of String => String),
            }},

            # removed a plugin
            "jit": Diff.new(nil, api.plugins.last),

            # added a plugin
            "jwt": Diff.new(cfg.plugins.last, nil),
          },
        })
      end
    end
  end
end
