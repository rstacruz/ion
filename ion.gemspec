# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ion/version'

Gem::Specification.new do |s|
  s.name = "ion"
  s.version = Ion::VERSION
  s.summary = %{Simple search engine powered by Redis.}
  s.description = %Q{Ion is a library that lets you index your records and search them with simple or complex queries.}
  s.authors = ["Rico Sta. Cruz"]
  s.email = ["rico@sinefunc.com"]
  s.homepage = "http://github.com/rstacruz/ion"
  s.files = `git ls-files -z`.split("\x0")
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_dependency "nest", "~> 1.0"
  s.add_dependency "redis", "~> 2.1"
  s.add_dependency "text", "~> 0.2.0"
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'ohm', '~> 2.2'
  s.add_development_dependency 'ohm-contrib', '~> 2.2'
  s.add_development_dependency 'batch', '~> 1.0.4'
end
