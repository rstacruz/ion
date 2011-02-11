module Ion
class Indices::Text < Index
  def index(record)
    super
    words = Stringer.keywords(value_for(record))
    refs  = references_key(record)

    words.each do |word|
      k = index_key[word]
      refs.sadd k
      k.zadd 1, record.id
    end
  end

  # Cleans the slate of the record
  def self.deindex(record)
    super
    refs = references_key(record)
    refs.smembers.each do |key|
      Ion.redis.zrem(key, record.id)
    end
  end

  def search(what)
    super
    words   = Stringer.keywords(what)
    keys    = words.map { |word| index_key[word] }

    Ion.intersect keys
  end
end
end
