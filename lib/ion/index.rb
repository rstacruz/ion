# An index
#
# You can subclass me by reimplementing #index, #deindex and #search.
#
class Ion::Index
  attr_reader :name
  attr_reader :options

  def initialize(name, options, extra={}, &blk)
    @name    = name
    @options = options
    @lambda  = blk  if block_given?
    @lambda  ||= Proc.new { self.send(name) }
  end

  # Indexes a record
  def index(record)
  end

  def self.deindex(record)
  end

  # Completely obliterates traces of a record from the indices
  def del(record)
    references_key(record).del
  end

  # Returns a key (set) of results
  def search(what)
  end

protected

  # Returns the value for a certain record
  def value_for(record)
    record.instance_eval &@lambda
  end

  # Returns the index key
  # Example: Ion:Album:text:title
  def index_key
    @type ||= self.class.name.split(':').last.downcase
    @options.key[@type][self.name]
  end

  # Ion:Album:references:1:text
  def self.references_key(record)
    type = self.name.split(':').last.downcase
    record.class.ion.key[:references][record.id][type]
  end

  def references_key(record)
    self.class.references_key record
  end
end
