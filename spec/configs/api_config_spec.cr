require "../spec_helper"

module Biplane
  describe ApiConfig do
    api = yaml_fixture(ApiConfig)

    it "knows collection path" do
      api.collection_route.should be_a(Route)
      api.collection_route.to_s.should eq "/apis"
    end

    it "knows instance path" do
      api.member_route.should be_a(Route)
      api.member_route.to_s.should eq "/apis/#{api.name}"
    end

    it "knows nested collections" do
      plugins = api.nested

      plugins.should be_a(Array(PluginConfig))
      plugins.map { |p| p.name }.should eq ["acl", "jwt"]
    end

    it "outputs attrs for create" do
      api.for_create.should eq({
        "name":               api.name,
        "request_path":       api.request_path,
        "strip_request_path": api.strip_request_path,
        "upstream_url":       api.upstream_url,
        "created_at":         "now",
      })
    end

    it "uses epoch time for update" do
      api.for_update.should eq({
        "name":               api.name,
        "request_path":       api.request_path,
        "strip_request_path": api.strip_request_path,
        "upstream_url":       api.upstream_url,
        "created_at":         Time.now.epoch,
      })
    end
  end
end
