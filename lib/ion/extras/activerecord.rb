raise Error, "ActiveRecord not found"  unless Object.const_defined?(:ActiveRecord)

require 'ion'

# Okay, this is probably wrong
class ActiveRecord::Base
  def self.acts_as_ion_indexable
    self.send :include, Ion::Entity
    self.after_save     :update_ion_indices
    self.before_destroy :delete_ion_indices
  end
end
