require "spec"
require "mock"

require "../src/biplane"

def build_json_fixture(type, name)
  type.from_json File.read("./spec/fixtures/#{name}.json")
end

def build_yaml_fixture(type, name)
  type.from_yaml File.read("./spec/fixtures/#{name}.yaml")
end

def json_fixture(type)
  base = type.name.split("::").last.downcase
  build_json_fixture(type, base)
end

def yaml_fixture(type)
  base = type.name.split("::").last.gsub("Config", "").downcase
  build_yaml_fixture(type, base)
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
