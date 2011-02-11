module Ion::Entity
  def self.included(to)
    to.extend ClassMethods
  end

  def update_ion_indices
    # Call me after saving
    ion = self.class.ion
    ion.index_types.each { |i_type| i_type.deindex(self) }
    ion.indices.each { |index| index.index(self) }
  end

  def delete_ion_indices
    # Call me before deletion
    ion = self.class.ion
    ion.index_types.each { |i_type| i_type.deindex(self) }
    ion.indices.each { |index| index.del(self) }
  end

  module ClassMethods
    # Sets up Ion indexing for a model.
    #
    # When no block is given, it returns the Ion::Options
    # for the model.
    #
    # @example
    #
    #   class Artist < Model
    #     include Ion::Entity
    #     ion {
    #       text :name
    #       text :real_name
    #     }
    #   end
    #
    #   Artist.ion.indices
    #   Artist.ion.search { ... }
    #
    def ion(&blk)
      @ion_options ||= Ion::Options.new(self)
      @ion_options.instance_eval(&blk)  if block_given?
      @ion_options
    end
  end
end
