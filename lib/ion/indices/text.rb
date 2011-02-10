class Ion::Indices::Text < Ion::Index
  def index(record)
    model    = record.class
    value    = record.send(self.name)
    keywords = Ion::Stringer.keywords(value)

    keywords.each do |word|
      keywords_key[word].sadd record.id
    end
  end

  def search(search)
    words   = Ion::Stringer.keywords(search.keywords)
    keys    = words.map { |word| keywords_key[word] }

    Ion.union keys
  end

protected
  def keywords_key
    @options.key[:keywords][self.name]
  end
end
