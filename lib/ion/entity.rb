module Ion::Entity
  def self.included(to)
    to.extend ClassMethods
  end

  def update_ion_indices
    # Call me after saving
    ion = self.class.ion
    ion.indices.each { |index| index.index(self) }
  end

  module ClassMethods
    def ion(&blk)
      @ion_options ||= Ion::Options.new(self)
      @ion_options.instance_eval(&blk)  if block_given?
      @ion_options
    end
  end
end
