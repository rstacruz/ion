require 'ion'
require 'sequel'

module Sequel::Plugins::IonIndexable
  def self.configure(model, options={}, &blk)
    model.send :include, Ion::Entity
    model.ion &blk  if block_given?
  end

  module InstanceMethods
    def after_save
      super; update_ion_indices
    end

    def before_destroy
      super; delete_ion_indices
    end
  end
end
