require "./spec_helper"

module Biplane
  describe Router do
    it "returns a plain route w/o interpolation" do
      Router.build(:apis).should eq("/apis")
    end

    it "can interpolate args" do
      Router.build(:credential, {
        username: "eye",
        name:     "cant",
        id:       "even",
      }).should eq "/consumers/eye/cant/even"
    end

    it "errors when missing keys" do
      expect_raises Router::MissingParam, /username, name/ do
        Router.build(:credentials)
      end
    end
  end
end
