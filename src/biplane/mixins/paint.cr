require "colorize"

module Biplane
  module Mixins::Paint
    def paint(string, color : Symbol)
      $COLORIZE ? string.colorize(color).to_s : string
    end

    def paint(string, color : Nil)
      string
    end
  end
end
