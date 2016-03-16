require "../spec_helper"

module Biplane
  class Dummy
    include Mixins::FlatFormatter

    def initialize(@obj)
    end

    def flattr
      flatten("config", @obj)
    end
  end

  describe Mixins::FlatFormatter do
    it "flattens hashes" do
      result = Dummy.new({
        one: 1.to_i64,
        two: {
          three: 3.to_i64,
          nine:  "niner",
        },
      }).flattr

      result.should eq({
        "config.one":       1,
        "config.two.three": 3,
        "config.two.nine":  "niner",
      })
    end

    it "flattens arrays" do
      result = Dummy.new([1, 2, 3]).flattr

      result.should eq({"config": "1,2,3"})
    end

    it "works with scalar values" do
      result = Dummy.new("hello").flattr

      result.should eq({"config": "hello"})
    end

    it "works with combined structures" do
      result = Dummy.new({
        one: "yes",
        two: {
          three: [1, 2, 3].map(&.to_i64),
          nine:  {"hello": "niner"},
        },
      }).flattr

      result.should eq({
        "config.one":            "yes",
        "config.two.three":      "1,2,3",
        "config.two.nine.hello": "niner",
      })
    end

    it "works with empty structures" do
      scalar_result = Dummy.new("").flattr
      array_result = Dummy.new([] of String).flattr
      hash_result = Dummy.new({} of String => String).flattr

      empty = Hash(String, Mixins::FlatFormatter::ValueTypes).new

      array_result.should eq(empty)
      hash_result.should eq(empty)
      hash_result.should eq(empty)
    end
  end
end
