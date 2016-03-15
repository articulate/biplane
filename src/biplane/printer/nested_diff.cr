module Biplane::Printer
  class NestedDiff
    def initialize(@diff)
    end

    # base level
    def print
      print(@diff, 0)
    end

    def print(diff : Hash, indent_level : Int32)
      diff.each do |k, v|
        print_at_indent("#{k}:", indent_level)
        print(v, indent_level + 1)
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

    private def print_at_indent(string : String, indent_level : Int32)
      indents = Array.new(indent_level, "  ").join("")
      puts indents + string
    end
  end
end
