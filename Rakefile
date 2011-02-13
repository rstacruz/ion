$:.unshift File.expand_path(File.join(File.dirname(__FILE__), 'test'))

task :test do
  Dir['test/**/*_test.rb'].each do |file|
    load file  unless file =~ /^-/
  end
end

task :irb do
  system 'irb -r./lib/ion.rb -r./test/irb_helpers'
end

namespace :bm do
  task :start do
    require 'benchmark_helper'
    Dir['test/benchmark/*.rb'].each do |file|
      load file
    end
  end

  task :spawn do
    require 'benchmark_helper'
    BM.spawn
  end
end

task :default => :test
