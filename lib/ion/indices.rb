module Ion
module Indices
  autoload :Text,      "#{Ion::PREFIX}/indices/text"
  autoload :Metaphone, "#{Ion::PREFIX}/indices/metaphone"

  def self.names
    [ :text, :metaphone ]
  end

  def self.get(name)
    name = Stringer.classify(name).to_sym
    raise InvalidIndexType  unless const_defined?(name)
    const_get(name)
  end
end
end
