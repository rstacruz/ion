module Ion
class Indices::Metaphone < Index
  def index(record)
    words = Stringer.keywords(value_for(record))
    words = words.map { |word| ::Text::Metaphone.metaphone word }

    words.each { |word| index_key[word].sadd record.id }
  end

  def search(what)
    words   = Stringer.keywords(what)
    words   = words.map { |word| ::Text::Metaphone.metaphone word }
    keys    = words.map { |word| index_key[word] }

    Ion.intersect keys
  end
end
end
