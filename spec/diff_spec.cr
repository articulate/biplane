require "./spec_helper"

module Biplane
  describe Diff do
    describe "apis" do
      it "added?" do
        diff = Diff.new(1, nil)

        diff.added?.should be_true
        diff.state.should eq :added
        diff.format.should eq "\e[32m+1\e[0m"
      end

      it "removed?" do
        diff = Diff.new(nil, 1)

        diff.removed?.should be_true
        diff.state.should eq :removed
        diff.format.should eq "\e[31m-1\e[0m"
      end

      it "changed?" do
        diff = Diff.new(1, 2)

        diff.changed?.should be_true
        diff.state.should eq :changed
        diff.format.should eq "\e[31m-2\e[0m\n\e[32m+1\e[0m"
      end

      it "not changed" do
        diff = Diff.new(1, 1)

        diff.changed?.should be_false
        diff.state.should eq nil
      end

      # mostly for tests
      it "can compare with other diffs" do
        diff1 = Diff.new(1, 2)
        diff2 = Diff.new(1, 2)
        diff3 = Diff.new(4, 5)

        diff1.should eq diff2
        diff1.should_not eq diff3
      end
    end
  end
end
