def F(*a)  File.join a.join('/').split('/'); end
def Fx(*a) File.expand_path F(*a); end
def Fr(*a) File.expand_path F(File.dirname(__FILE__), *a); end

$:.unshift Fr('../lib')

require 'ohm'
require 'ohm/contrib'
require 'ion'
require 'ffaker'
require 'contest'

class Test::Unit::TestCase
  def setup
    re = Redis.current
    keys = re.keys("Ion:*") + re.keys("Album:*")
    re.del(*keys)  if keys.any?
  end
end

