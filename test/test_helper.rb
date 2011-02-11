$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'ohm'
require 'ohm/contrib'
require 'ion'
require 'ffaker'
require 'contest'
require_relative './p_helper'

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

  after :save, :update_ion_indices
end

Album = IT::Album

