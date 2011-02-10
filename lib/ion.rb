require 'redis'
require 'nest'

module Ion
  PREFIX = File.join(File.dirname(__FILE__), 'ion')

  autoload :Stringer, "#{PREFIX}/stringer"
  autoload :Options,  "#{PREFIX}/options"
  autoload :Search,   "#{PREFIX}/search"
  autoload :Entity,   "#{PREFIX}/entity"
  autoload :Index,    "#{PREFIX}/index"

  module Indices
    autoload :Text,   "#{PREFIX}/indices/text"
  end

  def self.key
    @key ||= Nest.new('Ion')
  end

  # Returns a new temporary key.
  def self.volatile_key(ttl=30)
    k = key['~'][rand.to_s]
    k.expire ttl  if ttl > 0
    k
  end

  # Redis helper stuff
  # Probably best to move this somewhere

  # Combines multiple set keys.
  def self.union(keys)
    return keys.first  if keys.size == 1

    results = Ion.volatile_key
    keys.each { |key| results.sunionstore results, key }
    results
  end

  # Finds the intersection in multiple set keys.
  def self.intersect(keys)
    return keys.first  if keys.size == 1

    results = Ion.volatile_key
    results.sunionstore keys.first
    keys[1..-1].each { |key| results.sinterstore results, key }
    results
  end
end

# Ion:MODEL:keywords:FIELD:word
#
# Refactor todo:
# - Ion::Options should spawn Indices
# - Ion::Search#results should defer to Indices
# - Ion::Entity#update_ion_indices should defer to Indices
