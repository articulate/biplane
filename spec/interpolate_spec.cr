require "./spec_helper"

module Biplane
  describe Interpolate do
    interp = Interpolate.new("./spec/fixtures/interp.yml")

    it "can interpolate values in a config using string keys" do
      result = interp.apply({"my_val": "123", "athing": "456"})

      check_interp = YAML.parse(result)["plugins"][0]["attributes"]["config"]
      check_interp.should eq({"seacrest": "123", "password": "456"})
    end

    it "can write out a file" do
      file = MemoryIO.new(256)
      interp.save({"my_val": "123", "athing": "456"}, file)

      check_interp = YAML.parse(file.to_s)["plugins"][0]["attributes"]["config"]
      check_interp.should eq({"seacrest": "123", "password": "456"})
    end
  end
end
