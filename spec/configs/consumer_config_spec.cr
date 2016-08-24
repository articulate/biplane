require "../spec_helper"

module Biplane
  describe ConsumerConfig do
    consumer = yaml_fixture(ConsumerConfig)

    it "knows it's root path" do
      consumer.collection_route.should be_a(Route)
      consumer.collection_route.to_s.should eq "/consumers"
    end

    it "knows instance path" do
      consumer.member_route.should be_a(Route)
      consumer.member_route.to_s.should eq "/consumers/#{consumer.username}"
    end

    it "knows nested collections" do
      items = consumer.nested

      items.should be_a(Array(AclConfig | CredentialConfig))
      items.size.should eq 2
    end

    it "outputs attrs for create" do
      consumer.for_create.should eq({
        "username":   consumer.username,
        "created_at": "now",
      })
    end

    it "uses epoch time for update" do
      consumer.for_update.should eq({
        "username":   consumer.username,
        "created_at": Time.now.epoch,
      })
    end
  end
end
