require "../spec_helper"

module Biplane
  describe CredentialConfig do
    credential = yaml_fixture(CredentialConfig)
    credential.parent = parent = yaml_fixture(ConsumerConfig)

    it "can flatten for params" do
      credential.for_create.should eq({
        "key":    "xxx",
        "secret": "yyy",
      })
    end

    it "outputs epoch time for update" do
      credential.for_update.should eq({
        "key":        "xxx",
        "secret":     "yyy",
        "created_at": Time.now.epoch,
      })
    end

    it "knows collection path" do
      credential.collection_route.should be_a(Route)
      credential.collection_route.to_s.should eq "/consumers/#{parent.lookup_key}/#{credential.name}"
    end

    # requires actual UUID from API. will have to interpolate later
    it "knows instance path" do
      credential.member_route.should be_a(Route)
      credential.member_route.to_s.should eq "/consumers/#{parent.lookup_key}/#{credential.name}/:id"
    end
  end
end
