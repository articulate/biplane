require "./spec_helper"

module Biplane
  describe Route do
    route = Route.new("/one/:one/:two")

    it "can apply args" do
      route.to_s.should eq "/one/:one/:two"
      route.to_s({two: 2}).should eq "/one/:one/2"
    end

    it "can return partially applied route" do
      partial = route.partial({one: 1})

      partial.should be_a Route
      partial.should_not eq route
      partial.to_s.should eq "/one/1/:two"
    end

    it "ignores unknown path parts" do
      route.to_s({game: "on"}).should eq "/one/:one/:two"
    end

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
