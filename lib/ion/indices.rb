module Ion
module Indices
  autoload :Text,      "#{Ion::PREFIX}/indices/text"
  autoload :Number,    "#{Ion::PREFIX}/indices/number"
  autoload :Metaphone, "#{Ion::PREFIX}/indices/metaphone"
  autoload :Sort,      "#{Ion::PREFIX}/indices/sort"
  autoload :Boolean,   "#{Ion::PREFIX}/indices/boolean"

  def self.names
    [ :text, :number, :metaphone, :sort, :boolean ]
  end

  def self.get(name)
    name = Stringer.classify(name).to_sym
    raise InvalidIndexType  unless const_defined?(name)
    const_get(name)
  end
end
end
