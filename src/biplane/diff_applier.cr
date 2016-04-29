module Biplane
  class EmptyDiff < Exception; end

  class DiffApplier
    include Mixins::Paint

    def initialize(@client)
    end

    def apply(diff : Hash)
      raise EmptyDiff.new("Nothing to apply!") if diff.empty?

      diff.each do |name, diff|
        apply(diff)
      end
    end

    def apply(diff : Nil)
    end

    def apply(diff : Diff)
      return unless diff.changed?

      if !diff.root?
        @client.update(diff.roots[0] as Config, diff.roots[1] as Model)
      else
        case diff.state
        when :removed
          @client.destroy(diff)
        when :added
          @client.create(diff)
        when :changed
          @client.update(diff as Diff)
        end
      end
    end
  end
end
