require "./spec_helper"

module Biplane
  describe Router do
    it "returns a route w/o interpolation" do
      route = Router.build(:apis)

      route.should be_a(Route)
      route.to_s.should eq("/apis")
    end

    it "can interpolate args" do
      Router.build(:credential, {
        username: "eye",
        name:     "cant",
        id:       "even",
      }).to_s.should eq "/consumers/eye/cant/even"
    end

    it "returns raw path when params missing" do
      route = Router.build(:credential, {username: "hello"})
      route.to_s.should eq("/consumers/hello/:name/:id")
    end

    describe "validate!" do
      it "raises if incompletely interpolated path" do
        expect_raises Route::MissingParam, /username, name/ do
          Router.build!(:credentials)
        end
      end

      it "returns route if fully interpolated" do
        route = Router.build!(:credentials, {username: "yes", name: "no"})
        route.should be_a(Route)
      end
    end
  end
end
