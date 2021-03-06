require "spec_helper"

RSpec.describe DeadCodeDetector do
  class DeadCodeDetector::TestClass
    def self.foo; end
  end

  describe ".enable" do
    before do
      DeadCodeDetector::Initializer.refresh_cache_for(DeadCodeDetector::TestClass)
    end

    it "tracks method calls inside of the block" do
      expect do
        DeadCodeDetector.enable do
          DeadCodeDetector::TestClass.foo
        end
      end.to change{ DeadCodeDetector::Report.unused_methods_for(DeadCodeDetector::TestClass.name) }.from(["DeadCodeDetector::TestClass.foo"]).to([])

      expect(DeadCodeDetector.config.storage.pending_deletions).to be_empty
    end

    it "doesn't record method calls outside of the block" do
      DeadCodeDetector.enable {}
      DeadCodeDetector::TestClass.foo

      expect(DeadCodeDetector.config.storage.pending_deletions.values).to include(Set.new(["foo"]))
    end
  end
end
