$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'ohm'
require 'ohm/contrib'
require 'ion'
require 'batch'
require 'benchmark'
require_relative './p_helper'
require_relative './common_helper'

class BM
  class << self
    include LoremHelper

    def setup
      re = Redis.current
      keys = re.keys("Ion:*")
      re.del(*keys)  if keys.any?

      if Album.all.empty?
        puts "Did you spawn? Do `rake bm:spawn` first."
        exit
      end

      puts "-"*74
      puts "%-40s%10s%12s" % [ Time.now.strftime('%A, %b %d'), 'Elapsed', 'Records' ]
      puts "%-40s%10s%12s" % [ Time.now.strftime('%l:%M %p'),  'time',    'per sec' ]
      puts "-"*74
    end

    def time_for(&blk)
      GC.disable
      elapsed = Benchmark.realtime &blk
      GC.enable
      elapsed
    end


    def measure(test, size, &blk)
      start = Time.now
      print "%-40s" % [ "#{test} (x#{size})" ]

      elapsed = time_for(&blk) * 1000 #ms
      per     = elapsed / size
      rate    = size / (elapsed / 1000)

      puts "%10s%12s" % [ "#{elapsed.to_i} ms", "#{rate.to_i} /sec" ]
    end

    def re
      Ion.redis
    end

    def spawn(size=5000)
      keys = re.keys("IonBenchmark:*")
      re.del(*keys)  if keys.any?

      k = Album.send :key
      Batch.each((1..size).to_a) do |i|
        #Album.create title: lorem, body: lorem
        k[:all].sadd i
        k[i].hmset :title, lorem, :body, lorem
      end
    end
  end
end

module IonBenchmark
end

class IonBenchmark::Album < Ohm::Model
  include Ion::Entity
  include Ohm::Callbacks

  attribute :title
  attribute :body

  ion {
    text :title
    text :body
  }

  #after  :save,   :update_ion_indices
  #before :delete, :delete_ion_indices
end

Album = IonBenchmark::Album

