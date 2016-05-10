require "./spec_helper"

module Biplane
  describe Setup do
    setup = Setup.new("./spec/fixtures/testing.json")

    it "can read the config" do
      setup.config.should eq({
        "test":    1,
        "other":   "two",
        "shallow": true,
      })
    end

    describe "non-existant config" do
      new_path = "./spec/fixtures/nope.json"

      it "generates new" do
        File.exists?(new_path).should be_false

        Setup.new(new_path)
        File.exists?(new_path).should be_true
      end

      it "can read empty" do
        cfg = Setup.new(new_path)
        cfg.config.empty?.should be_true
      end

      File.delete new_path
    end

    describe "show" do
      it "prints the full confiug" do
        setup.show.should eq "test=1\nother=two\nshallow=true"
      end
    end

    describe "getting" do
      it "can get specific values by string" do
        setup.get("test").should eq 1
      end

      it "can get specific values by symbol" do
        setup.get(:other).should eq "two"
      end

      it "returns nil if value not set" do
        setup.get("hello").should be_nil
      end

      it "can specify a default" do
        setup.get("hello", "face").should eq "face"
      end

      it "does not set default in config" do
        setup.get("hello", "face").should eq "face"
        setup.get("hello").should be_nil
      end

      it "can get multiple values" do
        setup.gets("test", "hello").should eq([1, nil])
      end
    end

    describe "typed getters" do
      it "can cast ints" do
        int = setup.get_int("test", 800)

        int.should be_a(Int64)
        int.should eq(1)
      end

      it "can cast bools" do
        bool = setup.get_bool(:shallow, true)

        bool.should be_a(Bool)
        bool.should eq(true)
      end

      it "can cast strings" do
        string = setup.get_string("other", "hello")

        string.should be_a(String)
        string.should eq("two")
      end

      it "raises error if value isn't expected type" do
        expect_raises Exception, /cast to String/ do
          setup.get_string(:test, "yes")
        end
      end
    end

    describe "setting" do
      it "can set values" do
        setup.set(:yes, "sure")
        setup.config.should eq({
          "test":    1,
          "other":   "two",
          "shallow": true,
          "yes":     "sure",
        })
      end

      it "can set value to result of a block" do
        setup.set(:yes) do
          (1 + 2).to_i64
        end

        setup.get(:yes).should eq(3)
      end

      it "set values if not found" do
        setup.get("hello") { "or this" }.should eq "or this"
        setup.get("hello").should eq "or this"
      end

      it "does not set value if found" do
        setup.get("hello") { "not this" }.should eq "or this"
      end

      it "can set multiple and retains types when fetching" do
        setup.set(["hello=max", "one=1", "nox=true"])
        setup.gets("hello", "one", "nox").should eq(["max", 1, true])
      end
    end

    describe "unsetting" do
      it "can remove keys" do
        setup.remove("yes")
        setup.get("yes").should be_nil
      end

      it "succeeds quietly if key does not exist" do
        setup.remove("blah")
        setup.get("blah").should be_nil
      end

      it "can remove multiple" do
        setup.remove("hello", "one", "nox")
        setup.set?("hello").should be_false
        setup.set?("one").should be_false
        setup.set?("nox").should be_false
      end
    end

    describe "set?" do
      it "should be true when key is present" do
        setup.set?("test").should be_true
      end

      it "should be false when key is not present" do
        setup.set?("yess").should be_false
      end
    end
  end
end
