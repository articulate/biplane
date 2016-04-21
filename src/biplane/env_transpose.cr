module Biplane
  class EnvTranspose
    # "K=V [K=V]" pairs
    def self.transpose_env(kv_string : String)
      kvs = kv_string.split(" ")

      kvs.reduce({} of String => String) do |memo, kv_pair|
        key, value = kv_pair.split("=")
        memo[key] = value
        memo
      end
    end

    def self.transpose_hash(hash : Hash)
      hash.reduce({} of String => String) { |memo, k, v| memo[k.to_s] = v.to_s; memo }
    end

    # Raw JSON string
    def self.transpose_json(json : String)
      transpose_hash JSON.parse(json).as_h
    end

    # JSON files
    def self.transpose_json_file(path : String)
      transpose_hash transpose_json_file(File.open(path))
    end

    def self.transpose_json_file(io : IO)
      transpose_hash transpose_json(io.gets_to_end)
    end
  end
end
