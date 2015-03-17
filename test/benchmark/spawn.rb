require File.expand_path('../../benchmark_helper', __FILE__)
require 'batch'

class << BM
  def spawn(size=5000)
    re = Ion.redis

    keys = re.keys("IonBenchmark:*")
    re.del(*keys)  if keys.any?

    k = Album.send :key
    puts "k = #{k}"
    Batch.each((1..size).to_a) do |i|
      #Album.create title: lorem, body: lorem
      k[:all].sadd i
      k[i].hmset :title, lorem, :body, lorem
    end
  end
end

BM.spawn (ENV['BM_SIZE'] || 5000).to_i
