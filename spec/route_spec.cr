require "./spec_helper"

module Biplane
  describe Route do
    route = Route.new("/one/:one/:two")

    it "is idempotent" do
      route.to_s({one: 1}).should eq "/one/1/:two"
      route.to_s({one: 1}).should eq "/one/1/:two"
    end

    it "is non-mutating" do
      route.to_s({one: 1}).should eq "/one/1/:two"
      route.to_s({one: 2}).should eq "/one/2/:two"
      route.to_s.should eq "/one/:one/:two"
    end
  end
end
