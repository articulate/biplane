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
  end
end
