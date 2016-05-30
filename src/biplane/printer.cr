require "./printer/*"

module Biplane
  module Printer
    extend Mixins::Paint

    FORMATS = {
      "nested": NestedDiff,
      "flat":   FlatDiff,
    }

    def self.new(format = "nested")
      begin
        FORMATS[format].new
      rescue KeyError
        puts paint("Could not find formatter for '#{format}' (allowed: nested, flat).", :red)
        exit(1)
      end
    end
  end
end
