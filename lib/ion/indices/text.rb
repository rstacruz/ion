class Ion::Indices::Text < Ion::Index
  def index(record)
    value = record.send(self.name)
    words = Ion::Stringer.keywords(value)

    words.each { |word| index_key[word].sadd record.id }
  end

  def search(what)
    words   = Ion::Stringer.keywords(what)
    keys    = words.map { |word| index_key[word] }

    Ion.intersect keys
  end
end
