module Ion
class Indices::Number < Indices::Text
  MARGIN = 0.0001

  def index(record)
    value = value_for(record)
    [*value].each { |v| index_value record, v.to_f }
  end
    
  def index_value(record, value)
    value = value
    refs  = references_key(record)

    index_key.zadd value, record.id
    refs.sadd index_key
  end

  def search(what, args={})
    key = Ion.volatile_key
    key.zunionstore [index_key] #copy

    if what.is_a?(Hash)
      # Strip away the upper/lower limits.
      key.zremrangebyscore '-inf', what[:gt]  if what[:gt]
      key.zremrangebyscore what[:lt], '+inf'  if what[:lt]
      key.zremrangebyscore '-inf', (what[:min].to_f-MARGIN)  if what[:min]
      key.zremrangebyscore (what[:max].to_f+MARGIN), '+inf'  if what[:max]
    else
      key.zremrangebyscore '-inf', what.to_f-MARGIN
      key.zremrangebyscore what.to_f+MARGIN, '+inf'
    end

    key
  end
end
end
