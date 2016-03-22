require "colorize"

module Biplane
  class Diff
    UI = {
      removed: {symbol: "-", color: :red},
      added:   {symbol: "+", color: :green},
    }

    getter local, remote
    getter! roots

    def initialize(@local, @remote, @roots = nil)
      @roots ||= [@local, @remote]
    end

    def root?
      @local.is_a?(Config) || @remote.is_a?(Model)
    end

    def changed?
      @remote != @local
    end

    def added?
      !@local.nil? && @remote.nil?
    end

    def removed?
      @local.nil? && !@remote.nil?
    end

    def state
      if added?
        :added
      elsif removed?
        :removed
      elsif changed?
        :changed
      end
    end

    def empty?
      !changed?
    end

    def print
      puts format
    end

    def format(indent_level : Int32 = 0)
      format(diff_details, indent_level)
    end

    def format(details, indent_level : Int32 = 0)
      format(details, UI[state], indent_level)
    end

    def format(details, ui : Hash, indent_level : Int32 = 0)
      string = "#{ui[:symbol]} #{details}".colorize(ui[:color] as Symbol).to_s
      format_at_indent(string, indent_level)
    end

    def format(details : Array, indent_level : Int32 = 0)
      "#{format_removed(details[0], indent_level)}\n#{format_added(details[1], indent_level)}"
    end

    private def format_added(details, indent_level : Int32 = 0)
      format(details, UI[:added], indent_level)
    end

    private def format_removed(details, indent_level : Int32 = 0)
      format(details, UI[:removed], indent_level)
    end

    private def format_at_indent(string : String, indent_level : Int32)
      indents = Array.new(indent_level, "  ").join("")
      indents + string
    end

    def ==(other : Diff)
      @local == other.local &&
        @remote == other.remote
    end

    private def diff_details
      case state
      when :added
        @local
      when :removed
        @remote
      when :changed
        [@remote, @local]
      end
    end
  end
end
