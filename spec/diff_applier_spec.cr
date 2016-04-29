require "./spec_helper"

module Biplane
  describe DiffApplier do
    fake_client = double()

    describe "no change" do
      it "should error if nothing to apply" do
        applier = DiffApplier.new(fake_client)
        expect_raises EmptyDiff do
          applier.apply({} of String => Diff)
        end
      end

      it "should do nothing on nil" do
        fake_client.should_not_receive(:update)
        applier = DiffApplier.new(fake_client)

        applier.apply(nil).should be_nil
      end

      it "should do nothing if not changed" do
        fake_client.should_not_receive(:update)
        applier = DiffApplier.new(fake_client)

        applier.apply({"fake": Diff.new(1, 1)})
      end
    end
    describe "changes" do
      local = yaml_fixture(AclConfig)
      server = json_fixture(Acl)

      it "should update if not a root object" do
        diff = Diff.new(1, 2, [local, server])
        fake_client.should_receive(:update).with(local, server)
        applier = DiffApplier.new(fake_client)

        applier.apply({"fake": diff}).should eq({"fake": diff})
      end

      it "should remove if removed" do
        diff = Diff.new(nil, server)
        fake_client.should_receive(:destroy).with(diff)
        applier = DiffApplier.new(fake_client)

        applier.apply({"fake": diff}).should eq({"fake": diff})
      end

      it "should add if added" do
        diff = Diff.new(local, nil)
        fake_client.should_receive(:create).with(diff)
        applier = DiffApplier.new(fake_client)

        applier.apply({"fake": diff}).should eq({"fake": diff})
      end

      it "should update if updated root" do
        server.group = "marx"
        diff = Diff.new(local, server)
        fake_client.should_receive(:update).with(diff)
        applier = DiffApplier.new(fake_client)

        applier.apply({"fake": diff}).should eq({"fake": diff})
      end
    end
  end
end
