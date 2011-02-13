$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'ohm'
require 'ohm/contrib'
require 'ion'
require 'contest'
require_relative './p_helper'
#require_relative './redis_debug'

Ion.connect url: (ENV['REDIS_URL'] || 'redis://127.0.0.1:6379/0')

class Test::Unit::TestCase
  def setup
    re = Redis.current
    keys = re.keys("Ion:*") + re.keys("IT::*")
    re.del(*keys)  if keys.any?
  end

  def redis
    Ion.redis
  end

  def lorem
    (0..5).map { lorem_words[(lorem_words.length * rand).to_i] }.join(' ')
  end

  def lorem_words
    @w ||=
      %w(lorem ipsum dolor sit amet consecteteur adicicising elit sed do eiusmod) +
      %w(tempor incidudunt nam posture magna aliqua ut labore et dolore) +
      %w(cum sociis nostrud aequitas verificium)
  end

  def ids(keys)
    keys.map { |k| @items[k.to_sym].id }
  end

  def assert_ids(keys, args={})
    if args[:ordered]
      assert_equal ids(keys), args[:for].ids
    else
      assert_equal ids(keys).sort, args[:for].ids.sort
    end
  end
end

module IT
end

class IT::Album < Ohm::Model
  include Ion::Entity
  include Ohm::Callbacks

  attribute :title
  attribute :body

  ion {
    text :title
    text :body
    text(:also_title) { self.title }
  }

  after  :save,   :update_ion_indices
  before :delete, :delete_ion_indices
end

Album = IT::Album

