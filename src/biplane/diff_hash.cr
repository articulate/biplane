require "openssl"

module Biplane
  class DiffHash
    include Mixins::Paint

    def initialize(@diff)
      @hash = hash
    end

    def hash
      @hash ||= begin
        digest = OpenSSL::Digest.new "MD5"
        digest << @diff.to_s
        digest.to_s
      end
    end

    def equals?(given_hash)
      hash == given_hash
    end

    def print
      puts paint("Diff hash: #{hash}", :cyan)
    end
  end
end
