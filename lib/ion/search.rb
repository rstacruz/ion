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
    words = Ion::Stringer.keywords(@keywords)
    results = Array.new

    fields = @options.fields.keys
    fields.each do |field|
      key = @options.key[:keywords][field]
      words.each do |word|
        ids = key[word].smembers
        results += ids  unless ids.nil?
      end
    end

    results.uniq.map(&(@options.model))
  end

  def to_a
    results
  end

  def size
    results.size
  end
end
