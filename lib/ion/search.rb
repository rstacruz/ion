class Ion::Search
  include Enumerable

  attr_reader :key

  def initialize(options)
    @options = options
    @key     = Ion.volatile_key
  end

  def to_a
    ids.map(&(@options.model))
  end

  def each(&blk)
    to_a.each(&blk)
  end

  def ids
    @key.smembers
  end

  def size
    ids.size
  end

# Searching
  
  def text(field, what, options={})
    search :text, field, what, options
  end

  # Searches a given field
  def search(type, field, what, options={})
    key = @options.index(type, field).search(what)
    @key.sunionstore(@results, key)
  end
end
