$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'ohm'
require 'ohm/contrib'
require 'ion'
require 'contest'
require_relative './p_helper'
require_relative './common_helper'
#require_relative './redis_debug'

Ion.connect url: (ENV['REDIS_URL'] || 'redis://127.0.0.1:6379/15')

class Test::Unit::TestCase
  include LoremHelper

  def setup
    re = Redis.current
    keys = re.keys("Ion:*") + re.keys("IT::*")
    re.del(*keys)  if keys.any?
  end

  def redis
    Ion.redis
  end

  def scores_for(search)
    search.ids
    Hash[*search.key.zrange(0, -1, with_scores: true)]
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

  def assert_score(hash)
    hash.each do |key, score|
      assert_equal score.to_f, @scores[@items[key.to_sym].id].to_f
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
  attribute :play_count
  attribute :available

  ion {
    text :title
    text :body
    text(:also_title) { self.title }
    number :play_count
    boolean :available
    sort :title
  }

  def after_save
    update_ion_indices
  end

  def after_delete
    delete_ion_indices
  end
end

Album = IT::Album

