module Ion
class Indices::Metaphone < Index
  def index(record)
    value = value_for(record)
    words = ::Text::Metaphone.metaphone(value).strip.split(' ')

    words.each { |word| index_key[word].zadd 1, record.id }
  end

  def search(what)
    words   = ::Text::Metaphone.metaphone(what).strip.split(' ')
    keys    = words.map { |word| index_key[word] }

    Ion.intersect keys
  end
end
end
