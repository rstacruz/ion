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
    words = index_words(value_for(record).to_s)
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
      Ion.redis.del(key)  if Ion.redis.zrange(key,0,0).nil?
    end
  end

  def search(what, args={})
    super
    words   = search_words(what)
    keys    = words.map { |word| index_key[word] }

    w = keys.map { 0 }; w[0] = 1
    Ion.intersect keys, weights: w
  end
end
end
