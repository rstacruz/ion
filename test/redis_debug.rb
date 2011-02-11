# Redis debug
class Redis::Client
  def call(*args)
    puts "REDIS:" + args.inspect
    process(args) { read }
  end
end

