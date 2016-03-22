require "spec"
require "mock"

require "../src/biplane/*"

def json_fixture(type)
  base = type.name.split("::").last.downcase
  type.from_json File.read("./spec/fixtures/#{base}.json")
end

def yaml_fixture(type)
  base = type.name.split("::").last.gsub("Config", "").downcase
  type.from_yaml File.read("./spec/fixtures/#{base}.yaml")
end

def build_response(body : Hash | Nil, status = 200)
  build_response(body.to_json, status)
end

def build_response(body : String, status = 200)
  HTTP::Client::Response.new status, body: body
end

def load_response(type)
  build_response File.read("./spec/fixtures/manifest/#{type}s.json")
end
