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
      values = {"one": {"two": "three"}}
      result = Dummy.new(values).norm

      result.should eq(values)
    end

    it "knows how to parse arrays from comma-delimited strings" do
      result = Dummy.new({"four.five": "numbers,are,cool"}).norm
      result.should eq({"four": {"five": ["numbers", "are", "cool"]}})
    end

    it "can merge additional details" do
      result = Dummy.new({"one": {"two": "three"}}).norm({"four": "five"})
      result.should eq({"one": {"two": "three"}, "four": "five"})
    end
  end
end
