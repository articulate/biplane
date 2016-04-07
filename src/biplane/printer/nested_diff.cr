module Biplane::Printer
  class NestedDiff
    include Mixins::Colorize

    def initialize(@diff)
    end

    # base level
    def print
      print(@diff, 0)
    end

    def print(diff : Hash, indent_level : Int32)
      diff.each do |k, v|
        if v.is_a?(Diff) && v.added?
          print_addition(k, indent_level)
        elsif v.is_a?(Diff) && v.removed?
          print_removal(k, indent_level)
        else
          print_at_indent("#{k}:", indent_level)
          print(v, indent_level + 1)
        end
      end
    end

    def print(diff : Array, indent_level : Int32)
      print_at_indent("[", indent_level)

      diff.each do |v|
        print(v, indent_level + 1)
        puts "\n"
      end

      print_at_indent("]", indent_level)
    end

    def print(diff : Diff, indent_level : Int32)
      puts diff.format(indent_level).to_s
    end

    def print(diff, indent_level : Int32)
      print_at_indent(diff.to_s, indent_level)
    end

    private def print_addition(key, indent_level : Int32)
      print_at_indent(key, indent_level, "+", :green)
    end

    private def print_removal(key, indent_level : Int32)
      print_at_indent(key, indent_level, "-", :red)
    end

    private def print_at_indent(string : String, indent_level : Int32, prefix : String = "", color : Symbol = nil)
      indents = Array.new(indent_level, "  ").join("")

      text = (prefix + indents + string)
      puts colorize(text, color)
    end
  end
end
