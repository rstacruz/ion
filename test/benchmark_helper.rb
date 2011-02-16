$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'ohm'
require 'ohm/contrib'
require 'ion'
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

      puts "-"*62
      puts "%-40s%10s%12s" % [ Time.now.strftime('%A, %b %d -- %l:%M %p'), 'Elapsed', 'Rate' ]
      puts "-"*62
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
  end
end

module IonBenchmark
  class Album < Ohm::Model
    include Ion::Entity
    include Ohm::Callbacks

    attribute :title
    attribute :body

    ion {
      text :title
      text :body
    }

    # after  :save,   :update_ion_indices
    # before :delete, :delete_ion_indices
  end
end

Album = IonBenchmark::Album

