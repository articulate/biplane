module Biplane::Printer
  class FlatDiff
    def initialize(@diff)
    end

    # base level
    def print
      print(@diff)
    end

    def print(diff : Hash, keypath = "")
      diff.each do |k, v|
        update = keypath
        update += "." unless keypath == ""
        update += k

        print(v, update)
      end
    end

    def print(diff : Array, keypath)
      puts "["

      diff.each do |v|
        print(v, keypath)
        puts "\n"
      end

      puts "]"
    end

    def print(diff : Diff, keypath)
      puts keypath
      puts diff.format(1).to_s
    end

    def print(diff : Nil)
    end

    def print(diff, keypath)
      puts keypath
      puts diff
    end
  end
end
