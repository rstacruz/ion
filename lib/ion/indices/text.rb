module Ion
class Indices::Text < Index
  def index_words(str)
    Stringer.keywords str
  end

  def search_words(str)
    index_words str
  end

  def index(record)
    super
    words = index_words(value_for(record))
    refs  = references_key(record)

    words.each do |word|
      k = index_key[word]
      refs.sadd k
      k.zadd 1, record.id
    end
  end

  def self.deindex(record)
    super
    refs = references_key(record)
    refs.smembers.each do |key|
      Ion.redis.zrem(key, record.id)
    end
  end

  def search(what)
    super
    words   = search_words(what)
    keys    = words.map { |word| index_key[word] }

    Ion.intersect keys
  end
end
end
