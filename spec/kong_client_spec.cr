require "./spec_helper"

module Biplane
  describe KongClient do
    api_fixture = {
      data: [
        {
          created_at:   1454961927000,
          id:           "f9950bf1-8644-49a9-813a-a6543c91714e",
          name:         "library_public_api",
          uris:         ["/library"],
          strip_uri:    true,
          upstream_url: "https://example.com/public_queries",
        },
        {
          created_at:   1454447394000,
          id:           "3a1aa4ff-edc1-48c9-82d1-4125bc9fbb46",
          name:         "products_docs",
          uris:         ["/docs/products"],
          strip_uri:    true,
          upstream_url: "https://example.com/docs",
        },
        {
          created_at:   1454102626000,
          id:           "168d0fb3-cbe3-41da-a821-1dad41bafe06",
          name:         "products_admin_api",
          uris:         ["/admin/products"],
          strip_uri:    true,
          upstream_url: "https://example.com/admin/products",
        },
      ],
      total: 3,
    }

    empty_fixture = {
      data:  [] of JSON::Any,
      total: 0,
    }

    describe "fetching" do
      fake_client = double
      fake_client.stub(:close)
      client = KongClient.new(fake_client)

      describe "collection" do
        response = build_response(api_fixture)
        fake_client.stub(:get).with("/apis").and_return(response)

        res = client.apis

        it "should GET the /api endpoint" do
          res.should be_a(Array(Api))
          res.size.should eq(3)
        end

        it "should return Api objects" do
          res.first.should be_a(Api)
        end

        it "should have properties from the JSON blob" do
          res.first.name.should eq("library_public_api")
        end
      end

      describe "single" do
        response = build_response((api_fixture[:data] as Array)[0])
        fake_client.stub(:get).with("/apis/library_public_api").and_return(response)

        res = client.api({name: "library_public_api"})

        it "should return singular Api objects by name" do
          res.should be_a(Api)
        end

        it "should have properties from the JSON blob" do
          res.name.should eq("library_public_api")
        end
      end

      describe "empty result" do
        response = build_response(empty_fixture)

        it "returns an empty array of type" do
          fake_client.stub(:get).with("/consumers").and_return(response)
          client.consumers.should eq([] of Consumer)
        end
      end

      describe "handles not found" do
        response = build_response({"message": "Not found"}, 404)

        it "should return empty when collection" do
          api = json_fixture(Api)
          fake_client.stub(:get).with("/apis/#{api.name}/plugins").and_return(response)
          api.client = client

          api.plugins.should eq([] of Plugin)
        end

        it "should error when specific" do
          fake_client.stub(:get).with("/apis/derp-a-derp").and_return(response)

          expect_raises KongClient::NotFound do
            client.api({name: "derp-a-derp"})
          end
        end
      end
    end

    describe "failure" do
      fake_client = double
      fake_client.stub(:close)
      client = KongClient.new(fake_client)

      failure_response = build_response(nil, 500)
      fake_client.stub(:get).with("/apis").and_return(failure_response)

      it "raises an exception" do
        expect_raises KongClient::APIError, /status code 500/ do
          client.apis
        end
      end
    end
  end
end
