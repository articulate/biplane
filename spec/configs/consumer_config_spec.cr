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
  end
end
