class Ion::Indices::Text < Ion::Index
  def index(record)
    value = record.send(self.name)
    words = Ion::Stringer.keywords(value)

    words.each { |word| keywords_key[word].sadd record.id }
  end

  def search(what)
    words   = Ion::Stringer.keywords(what)
    keys    = words.map { |word| keywords_key[word] }

    Ion.intersect keys
  end

protected
  def keywords_key
    @options.key[:keywords][self.name]
  end
end
