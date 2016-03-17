module Biplane
  class Route
    KEY = /(:\w+)/

    class MissingParam < Exception; end

    def initialize(@path, @args = {} of String => String)
    end

    def to_s(args = {} of String => String, force = false)
      interpolate(@args.merge(args))
    end

    def to_s!(args : Hash)
      to_s(args, force: true)
    end

    def partial(args : Hash)
      self.class.new(@path, args)
    end

    def validate!
      interpolate(force: true)
      self
    end

    private def interpolate(args = @args, force = false : Bool)
      required = @path.scan(KEY).map(&.[1].sub(':', ""))
      diff = (required - args.keys.map(&.to_s))

      raise MissingParam.new("Missing arguments #{diff.join(", ")}.") if force && !diff.empty?

      args.reduce(@path) do |memo, k, v|
        memo.gsub(":#{k}", v)
      end
    end
  end
end
