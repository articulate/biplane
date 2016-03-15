require "./spec_helper"

module Biplane
  describe ConfigManifest do
    config = ConfigManifest.new("./spec/fixtures/dummy.yaml")

    it "can load from a file path" do
      config.apis.should be_a(Array(ApiConfig))
    end

    it "can load from a file" do
      f = File.open("./spec/fixtures/dummy.yaml")
      config = ConfigManifest.new(f)
      config.consumers.should be_a(Array(ConsumerConfig))
    end

    it "parses entire config" do
      acl = config.consumers.first.acls.first

      acl.should be_a(AclConfig)
      acl.group.should eq("google-auth")
    end

    it "can serialize self" do
      config.serialize.should eq({
        "apis": [
          {
            "name":       "products_admin_api",
            "attributes": {
              "request_path":       "/admin/products",
              "strip_request_path": true,
              "upstream_url":       "http://www.example.com/admin/products",
            },
            "plugins": [
              {
                "name":       "acl",
                "attributes": {
                  "config": {
                    "whitelist": [
                      "google-auth",
                    ],
                  },
                },
              },
              {
                "name":       "jwt",
                "attributes": {
                  "config": {
                    "key_claim_name":   "aud",
                    "secret_is_base64": true,
                    "uri_param_names":  [
                      "jwt",
                    ],
                  },
                },
              },
            ],
          },

        ],
        "consumers": [
          {
            "username": "google-auth",
            "acls":     [
              {
                "group": "google-auth",
              },
            ],
            "credentials": [
              {
                "name":       "jwt",
                "attributes": {
                  "key":    "xxx",
                  "secret": "yyy",
                },
              },
            ],
          },
          {
            "username": "docs-user",
            "acls":     [
              {
                "group": "docs",
              },
            ],
            "credentials": [
              {
                "name":       "basic-auth",
                "attributes": {
                  "username": "abc",
                  "password": "efg",
                },
              },
            ],
          },
        ],
      })
    end
  end
end
