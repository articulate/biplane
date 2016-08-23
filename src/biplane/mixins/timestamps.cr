module Biplane::Mixins
  module Timestamps
    def pg_now
      Time.now.epoch
    end
  end
end
