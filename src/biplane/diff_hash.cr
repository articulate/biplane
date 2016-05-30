require "openssl"

module Biplane
  class DiffHash
    def self.hash(diff)
      digest = OpenSSL::Digest.new "MD5"
      digest << diff.to_s
      digest.to_s
    end
  end
end
