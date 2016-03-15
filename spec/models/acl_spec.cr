require "../spec_helper"

module Biplane
  describe Acl do
    acl = json_fixture(Acl)
    cfg = yaml_fixture(AclConfig)

    it "can check equality" do
      acl.should eq(cfg)
    end

    it "fails when not equal" do
      cfg.group = "hello"
      acl.should_not eq(cfg)
    end

    it "can diff" do
      acl.diff(cfg).should eq({"group": Diff.new(cfg.group, acl.group)})
    end
  end
end
