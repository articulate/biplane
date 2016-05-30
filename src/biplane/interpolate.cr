module Biplane
  class Interpolate
    getter :template

    @template : Crustache::Syntax::Template

    def initialize(io : IO)
      @template = Crustache.parse io.gets_to_end
    end

    def initialize(path : String)
      @template = Crustache.parse File.read(path)
    end

    # assumes all keys are string
    def apply(context : Hash(String, String))
      Crustache.render(@template, context)
    end

    def save(context, output : IO = STDOUT)
      output << apply(context)
    end
  end
end
