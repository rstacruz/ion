class Ion::Search
  def initialize(options)
    @options = options
  end

  def keywords(keywords=nil)
    @keywords ||= ''
    @keywords = keywords  unless keywords.nil?
    @keywords
  end

  def results
    keys = @options.indices.map { |_, index| index.search(self) }
    results = Ion.union(keys)
    results.smembers.uniq.map(&(@options.model))
  end

  def to_a
    results
  end

  def size
    results.size
  end
end
