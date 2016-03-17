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
