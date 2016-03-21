require "../spec_helper"

module Biplane
  class Dummy
    include Mixins::NormalizeAttributes

    def initialize(@obj)
    end

    def norm(extras = Hash(String, String).new)
      normalize(@obj, extras)
    end
  end

  describe Mixins::NormalizeAttributes do
    it "normalizes single key syntax" do
      result = Dummy.new({"one.two": "three"}).norm

      result.should eq({"one": {"two": "three"}})
    end

    it "leaves regular hashes alone" do
      values = {"one": {"two": "three"}, "four": ["numbers", "are", "cool"]}
      result = Dummy.new(values).norm

      result.should eq(values)
    end

    it "can merge additional details" do
      result = Dummy.new({"one": {"two": "three"}}).norm({"four": "five"})
      result.should eq({"one": {"two": "three"}, "four": "five"})
    end
  end
end
