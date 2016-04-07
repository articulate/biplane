require "./printer/*"

module Biplane
  module Printer
    extend Mixins::Paint

    class EmptyDiff
      include Mixins::Paint

      def initialize(@diff)
      end

      def print
        puts paint("No differences found!", :green)
      end
    end

    FORMATS = {
      "nested": NestedDiff,
      "flat":   FlatDiff,
      "empty":  EmptyDiff,
    }

    def self.new(diff, format = "nested")
      format = "empty" if diff.empty?

      begin
        FORMATS[format].new(diff)
      rescue KeyError
        puts paint("Could not find formatter for '#{format}' (allowed: nested, flat).", :red)
        exit(1)
      end
    end
  end
end
