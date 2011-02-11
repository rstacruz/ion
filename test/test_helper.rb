$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'ohm'
require 'ohm/contrib'
require 'ion'
require 'ffaker'
require 'contest'

class Test::Unit::TestCase
  def setup
    re = Redis.current
    keys = re.keys("Ion:*") + re.keys("IT::*")
    re.del(*keys)  if keys.any?
  end
end

module IT
end
