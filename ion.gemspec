Gem::Specification.new do |s|
  s.name = "ion"
  s.version = "0.0.1"
  s.summary = %{Simple search engine powered by Redis.}
  s.description = %Q{Ion is a library that lets you index your records and search them with simple or complex queries.}
  s.authors = ["Rico Sta. Cruz"]
  s.email = ["rico@sinefunc.com"]
  s.homepage = "http://github.com/rstacruz/ion"
  s.files = ["lib/ion/config.rb", "lib/ion/entity.rb", "lib/ion/helpers.rb", "lib/ion/index.rb", "lib/ion/indices/metaphone.rb", "lib/ion/indices/number.rb", "lib/ion/indices/sort.rb", "lib/ion/indices/text.rb", "lib/ion/indices.rb", "lib/ion/options.rb", "lib/ion/scope.rb", "lib/ion/search.rb", "lib/ion/stringer.rb", "lib/ion.rb", "README.md", "Rakefile", "test/irb_helpers.rb", "test/p_helper.rb", "test/redis_debug.rb", "test/test_helper.rb", "test/unit/boost_test.rb", "test/unit/config_test.rb", "test/unit/hash_test.rb", "test/unit/ion_test.rb", "test/unit/metaphone_test.rb", "test/unit/number_test.rb", "test/unit/options_test.rb", "test/unit/range_test.rb", "test/unit/score_test.rb", "test/unit/sort_test.rb", "test/unit/subscope_test.rb", "test/unit/ttl_test.rb", "test/unit/update_test.rb"]
  s.add_dependency "nest", "~> 1.0"
  s.add_dependency "redis", "~> 2.1"
  s.add_dependency "text", "~> 0.2.0"
end
