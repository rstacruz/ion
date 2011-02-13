require 'redis'
require 'nest'
require 'text'

module Ion
  PREFIX = File.join(File.dirname(__FILE__), 'ion')

  # How long until search keys expire.
  DEFAULT_TTL = 30

  autoload :Stringer, "#{PREFIX}/stringer"
  autoload :Options,  "#{PREFIX}/options"
  autoload :Search,   "#{PREFIX}/search"
  autoload :Entity,   "#{PREFIX}/entity"
  autoload :Index,    "#{PREFIX}/index"
  autoload :Indices,  "#{PREFIX}/indices"
  autoload :Scope,    "#{PREFIX}/scope"
  autoload :Helpers,  "#{PREFIX}/helpers"

  InvalidIndexType = Class.new(StandardError)
  Error            = Class.new(StandardError)

  # Returns the Redis instance that is being used by Ion.
  def self.redis
    @redis || key.redis
  end

  # Connects to a certain Redis server.
  def self.connect(to)
    @redis = Redis.connect(to)
  end

  # Returns the root key.
  def self.key
    @key ||= if @redis
      Nest.new('Ion', @redis)
    else
      Nest.new('Ion')
    end
  end

  # Returns a new temporary key.
  def self.volatile_key
    key['~'][rand.to_s]
  end

  # Makes a certain volatile key expire.
  def self.expire(*keys)
    keys.each { |k| redis.expire(k, DEFAULT_TTL)  if k.include?('~') }
  end

  # Redis helper stuff
  # Probably best to move this somewhere

  # Combines multiple set keys.
  def self.union(keys, options={})
    return keys.first  if keys.size == 1

    results = Ion.volatile_key
    results.zunionstore keys, options
    results
  end

  # Finds the intersection in multiple set keys.
  def self.intersect(keys, options={})
    return keys.first  if keys.size == 1

    results = Ion.volatile_key
    results.zinterstore keys, options
    results
  end
end
