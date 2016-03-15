require "../spec_helper"

module Biplane
  describe Consumer do
    consumer = json_fixture(Consumer)
    cfg = yaml_fixture(ConsumerConfig)

    fake_client = double
    fake_client.stub(:close)

    cred_fixture = {
      "data": [
        {
          "consumer_id": "f52b5a59-c63a-4afa-92e4-88ac8783c8d8",
          "created_at":  1456414795000,
          "id":          "110edeb6-1afc-4f92-a894-724d17bf9325",
          "key":         "xxx",
          "secret":      "yyy",
        },
      ],
      "total": 1,
    }

    acls = {
      "data": [
        {
          "consumer_id": "6c460159-65dd-4016-aaf9-bcb58b0951cf",
          "created_at":  1456856994000,
          "group":       "google-auth",
          "id":          "cc267b0e-02c4-4ec3-98d0-b083aac3bf75",
        },
      ],
      "total": 1,
    }

    fake_client.stub(:get).with("/consumers/google-auth/acl").and_return(build_response(cred_fixture))
    fake_client.stub(:get).with("/consumers/google-auth/acls").and_return(build_response(acls))

    consumer.client = KongClient.new(fake_client)
    consumer.cache_credentials([json_fixture(Plugin)])

    it "can compare with config objects" do
      consumer.should eq(cfg)
    end

    describe "different" do
      consumer.username = "dope"

      it "is not equal" do
        consumer.should_not eq(cfg)
      end

      it "returns a diff" do
        consumer.diff(cfg).should eq({"username" => Diff.new("google-auth", "dope")})
      end
    end

    describe "child resources" do
      it "can fetch credentials" do
        consumer.credentials.size.should eq(1)
        consumer.credentials.should be_a(ChildCollection(Credential))
      end

      it "can fetch acls" do
        consumer.acls.size.should eq(1)
        consumer.acls.should be_a(ChildCollection(Acl))
      end
    end
  end
end
