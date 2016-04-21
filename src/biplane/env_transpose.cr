module Biplane
  class EnvTranspose
    # "K=V [K=V]" pairs
    def self.transpose_kv_string(kv_string : String)
      kvs = kv_string.split(" ")

      transpose_kv_pairs(kvs)
    end

    def self.transpose_kv_pairs(kv_pairs : Array)
      kv_pairs.reduce({} of String => String) do |memo, kv_pair|
        key, value = kv_pair.split("=")
        memo[key] = value
        memo
      end
    end

    def self.transpose_ini_file(path : String)
      transpose_ini_file File.open(path)
    end

    def self.transpose_ini_file(io : IO)
      transpose_kv_pairs io.gets_to_end.chomp.split('\n')
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
