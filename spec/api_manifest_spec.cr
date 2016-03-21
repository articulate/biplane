require "./spec_helper"

module Biplane
  describe ApiManifest do
    fake_client = double
    fake_client.stub(:get).with("/apis").and_return(load_response(:api))
    fake_client.stub(:get).with("/consumers").and_return(load_response(:consumer))
    fake_client.stub(:get).with("/apis/library_public_api/plugins").and_return(load_response(:plugin))
    fake_client.stub(:get).with("/consumers/docs-user/acl").and_return(load_response(:acl_credential))
    fake_client.stub(:get).with("/consumers/docs-user/jwt").and_return(load_response(:jwt_credential))
    fake_client.stub(:get).with("/consumers/docs-user/acls").and_return(load_response(:acl))
    fake_client.stub(:close)

    manifest = ApiManifest.new(KongClient.new(fake_client))

    it "parses entire api" do
      acl = manifest.consumers.last.acls.first

      acl.should be_a(Acl)
      acl.group.should eq("google-auth")
    end

    it "can serialize" do
      manifest.serialize.should eq({
        "apis" => [
          {
            "name"       => "library_public_api",
            "attributes" => {
              "request_path"       => "/content-library",
              "strip_request_path" => true,
              "upstream_url"       => "http://example.com/public_queries",
            },
            "plugins" => [
              {
                "name"       => "acl",
                "attributes" => {
                  "config" => {"whitelist" => "google-auth"},
                },
              },
              {
                "name"       => "jwt",
                "attributes" => {
                  "config" => {
                    "key_claim_name"   => "aud",
                    "secret_is_base64" => true,
                    "uri_param_names"  => "jwt",
                  },
                },
              },
            ],
          },
        ], "consumers" => [
        {
          "username"    => "docs-user",
          "credentials" => [{
            "name"       => "acl",
            "attributes" => {"key" => "aaa", "secret" => "bbb"},
          }, {
            "name"       => "jwt",
            "attributes" => {
              "key"    => "xxx",
              "secret" => "yyy",
            },
          }], "acls" => [{"group" => "google-auth"}],
        },
      ],
      })
    end

    describe "comparator" do
      it "should be equal to generated dump" do
        yaml = YAML.dump(manifest.serialize)
        config = ConfigManifest.from_yaml(yaml)

        manifest.should eq(config)
      end

      it "should not be equal when different" do
        config = ConfigManifest.new("./spec/fixtures/dummy.yaml")

        manifest.should_not eq(config)
      end

      it "can generate a diff" do
        config = ConfigManifest.new("./spec/fixtures/manifest/output_for_diff.yml")

        manifest.diff(config).should eq({
          "apis": {
            "library_public_api": {
              "plugins" => {
                "acl": {"attributes" => {"config" => Diff.new(
                  {"whitelist" => ["trump", "clinton"]},
                  {"whitelist" => "google-auth"},
                )}},
                "jwt": {"attributes" => {"config" => Diff.new(
                  {"key_claim_name" => "aud", "secret_is_base64" => false, "uri_param_names" => "jwt"},
                  {"key_claim_name" => "aud", "secret_is_base64" => true, "uri_param_names" => "jwt"},
                )}},
              },
            },
          },
          "consumers" => {
            "docs-user" => {"credentials" => {"jwt" => {"attributes" => {
              "key"    => Diff.new("fff", "xxx"),
              "secret" => Diff.new("ccc", "yyy"),
            }}}},
          },
        })
      end
    end
  end
end
