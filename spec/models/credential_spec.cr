require "../spec_helper"

module Biplane
  describe Credential do
    cfg = yaml_fixture(CredentialConfig)

    cred = json_fixture(Credential)
    plugin = cred.plugin = json_fixture(Plugin)

    it "knows member route" do
      cred.parent = parent = json_fixture(Consumer)
      cred.member_route.to_s.should eq "/consumers/#{parent.username}/#{plugin.name}/#{cred.id}"
    end

    it "can compare with config objects" do
      cred.should eq(cfg)
    end

    it "can handle checking hashed passwords" do
      pw_cred = Credential.from_json({
        "consumer_id": "f52b5a59-c63a-4afa-92e4-88ac8783c8d8",
        "created_at":  1456414795000,
        "id":          "110edeb6-1afc-4f92-a894-724d17bf9325",
        "username":    "bosh",
        "password":    "aac0a447e69dfdf4583ea3e8ec91ce597ac37d52",
      }.to_json)
      pw_cred.plugin = plugin

      pw_cfg = CredentialConfig.from_yaml(YAML.dump({
        "name":       plugin.name,
        "attributes": {
          "username": "bosh",
          "password": "testing",
        },
      }))

      pw_cred.should eq(pw_cfg)
    end

    describe "different" do
      cfg.name = "yowza"
      cred.secret = "seacrest"

      it "is not equal" do
        cred.should_not eq(cfg)
      end

      it "can diff" do
        cred.diff(cfg).should eq({
          "name":       Diff.new("yowza", "acl"),
          "attributes": {"secret": Diff.new("yyy", "seacrest")},
        })
      end
    end
  end
end
