module Biplane::Mixins
  module Timestamps
    def pg_now
      "now"
    end
  end
end
