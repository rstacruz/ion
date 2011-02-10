require 'redis'
require 'nest'

module Ion
  PREFIX = File.join(File.dirname(__FILE__), 'ion')

  autoload :Stringer, "#{PREFIX}/stringer"
  autoload :Options,  "#{PREFIX}/options"
  autoload :Search,   "#{PREFIX}/search"
  autoload :Entity,   "#{PREFIX}/entity"

  module Indices
    autoload :Text,   "#{PREFIX}/indices/text"
  end

  def self.key
    @key ||= Nest.new('Ion')
  end
end

# Ion:MODEL:keywords:FIELD:word
#
# Refactor todo:
# - Ion::Options should spawn Indices
# - Ion::Search#results should defer to Indices
# - Ion::Entity#update_ion_indices should defer to Indices
