require "../spec_helper"

module Biplane
  describe AclConfig do
    acl = yaml_fixture(AclConfig)
    acl.parent = parent = yaml_fixture(ConsumerConfig)

    it "knows collection path" do
      acl.collection_route.should be_a(Route)
      acl.collection_route.to_s.should eq "/consumers/#{parent.lookup_key}/acls"
    end

    # requires actual UUID from API. will have to interpolate later
    it "knows instance path" do
      acl.member_route.should be_a(Route)
      acl.member_route.to_s.should eq "/consumers/#{parent.lookup_key}/acls/:id"
    end

    it "outputs attrs for create" do
      acl.for_create.should eq({
        "group": acl.group,
      })
    end

    it "uses epoch time for update" do
      acl.for_update.should eq({
        "group":      acl.group,
        "created_at": Time.now.epoch,
      })
    end
  end
end
