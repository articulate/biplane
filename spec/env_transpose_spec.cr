require "./spec_helper"

module Biplane
  describe EnvTranspose do
    it "creates a hash from a K=V string" do
      res = EnvTranspose.transpose_env("K=v X=y fake=yes")

      res.should be_a Hash(String, String)
      res.should eq({
        "K":    "v",
        "X":    "y",
        "fake": "yes",
      })
    end

    it "creates a hash from a json blob" do
      res = EnvTranspose.transpose_json({x: "one", t: "more", yes: "time"}.to_json)

      res.should be_a Hash(String, String)
      res.should eq({
        "x":   "one",
        "t":   "more",
        "yes": "time",
      })
    end

    it "creates a hash from a json file" do
      res = EnvTranspose.transpose_json_file("./spec/fixtures/env.json")
      res.should be_a Hash(String, String)

      res.should eq({
        "test": "1",
        "face": "book",
        "not":  "true",
      })
    end

    it "ensures string keys for hashes" do
      res = EnvTranspose.transpose_hash({x: "one", t: "more", yes: "time"})

      res.should be_a Hash(String, String)
      res.should eq({
        "x":   "one",
        "t":   "more",
        "yes": "time",
      })
    end
  end
end
