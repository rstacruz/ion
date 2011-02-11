module Ion
class Indices::Text < Index
  def index(record)
    words = Stringer.keywords(value_for(record))
    words.each { |word| index_key[word].sadd record.id }
  end

  def search(what)
    words   = Stringer.keywords(what)
    keys    = words.map { |word| index_key[word] }

    Ion.intersect keys
  end
end
end
