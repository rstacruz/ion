class Ion::Search
  include Enumerable

  def initialize(options)
    @options = options
    @results = Ion.volatile_key
  end

  def to_a
    ids.map(&(@options.model))
  end

  def each(&blk)
    to_a.each(&blk)
  end

  def ids
    @results.smembers
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
    @results.sunionstore(@results, key)
  end
end
