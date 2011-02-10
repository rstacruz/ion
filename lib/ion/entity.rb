module Ion::Entity
  def self.included(to)
    to.extend ClassMethods
  end

  def update_ion_indices
    # Call me after saving
    ion = self.class.ion
    key = ion.key
    id  = self.id

    ion.fields.each do |name, field|
      value    = self.send(name)
      keywords = Ion::Stringer.keywords(value)
      keywords.each do |word|
        key[:keywords][name][word].sadd id
      end
    end
  end

  module ClassMethods
    def ion(&blk)
      @ion_options ||= Ion::Options.new(self)
      @ion_options.instance_eval(&blk)  if block_given?
      @ion_options
    end
  end
end
