module Biplane::Mixins
  module Timestamps
    def pg_now
      "now"
    end

    def epoch_int
      Time.now.epoch
    end
  end
end
