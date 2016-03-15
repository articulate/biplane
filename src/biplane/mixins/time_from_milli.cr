module Biplane::Mixins
  module TimeFromMilli
    def self.from_json(pull : JSON::PullParser)
      Time.epoch_ms(pull.read_int)
    end

    def self.to_json(value, io)
      io << value.total_milliseconds.to_i64
    end
  end
end
