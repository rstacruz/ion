module Ion
class Indices::Boolean < Indices::Text
  def index(record)
    value = value_for(record)
    value = bool_to_str(value)
    refs  = references_key(record)

    index_key[value].zadd 1, record.id
    refs.sadd index_key[value]
  end

  def search(what, args={})
    what = bool_to_str(what)
    index_key[what]
  end

protected
  def bool_to_str(value)
    str_to_bool(value) ? "1" : "0"
  end

  def str_to_bool(value)
    value = value.downcase  if value.is_a?(String)
    case value
      when 'false', false, '0', 0 then false
      else true
    end
  end
end
end
