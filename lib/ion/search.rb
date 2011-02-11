class Ion::Search
  def initialize(options)
    @options = options
    @results = Ion.volatile_key
  end

  def results
    @results.smembers.uniq.map(&(@options.model))
  end

  def to_a
    results
  end

  def size
    results.size
  end

  def keywords
    @keywords ||= ''
  end

# Searching
  
  def text(field, what, options={})
    search :text, field, what, options
  end

  # Searches a given field
  def search(type, field, what, options={})
    @keywords = what

    key = @options.index(type, field).search(self)
    @results.sunionstore(@results, key)
  end
end
