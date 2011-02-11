class Ion::Indices::Metaphone < Ion::Index
  def index(record)
    value = record.send(self.name)
    words = Ion::Stringer.keywords(value)
    words = words.map { |word| ::Text::Metaphone.metaphone word }

    words.each { |word| index_key[word].sadd record.id }
  end

  def search(what)
    words   = Ion::Stringer.keywords(what)
    words   = words.map { |word| ::Text::Metaphone.metaphone word }
    keys    = words.map { |word| index_key[word] }

    Ion.intersect keys
  end
end
