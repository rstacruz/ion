require 'bundler/gem_tasks'
require 'fileutils'
$:.push File.expand_path('../test', __FILE__)
$:.push *Dir[File.expand_path('../vendor/*/lib', __FILE__)]


module Util
  def redis_port
    6379
  end

  def redis_url(db=0)
    "redis://127.0.0.1:#{redis_port}/#{db}"
  end

  def redis?
    ! redis_pid.nil?
  end

  def redis_pid
    begin
      id = File.read(redis_pidfile).strip.to_i
      return id  if Process.getpgid(id)
    rescue => e
    end
  end

  def redis_path(*a)
    File.join(File.expand_path('../db', __FILE__), *a)
  end

  def redis_pidfile
    redis_path 'redis.pid'
  end

  def redis_start
    FileUtils.mkdir_p redis_path
    system "( echo port #{redis_port}; echo pidfile #{redis_path}/redis.pid; echo dir #{redis_path}; echo daemonize yes ) | redis-server -"
  end

  def system(cmd)
    puts "\033[0;33m$\033[0;m #{cmd}"
    super
  end

  def info(cmd)
    puts "\033[0;33m*\033[0;32m #{cmd}\033[0;m"
  end
end

Object.send :include, Util

desc "Starts redis."
task :'redis:start' do
  if redis?
    info "Redis is running at #{redis_pid} (port #{redis_port}) -- `rake redis:stop` to stop."
  else
    info "Starting redis server at #{redis_port}."
    redis_start
  end
end

desc "Stops redis."
task :'redis:stop' do
  info "Stopping redis..."
  system "redis-cli -p #{redis_port} shutdown"
end

desc "Runs tests."
task :'test' => :'redis:start' do
  ENV['REDIS_URL'] = redis_url(0)
  Dir['test/**/*_test.rb'].each { |f| load f }
end

Dir['test/benchmark/*.rb'].each do |f|
  base = File.basename(f, '.*')
  desc "Run the '#{base}' benchmark."
  task :"bm:#{base}" => :'redis:start' do
    ENV['REDIS_URL'] = redis_url(1)
    load f
  end
end

task :redis => :'redis:start'
task :default => :test
