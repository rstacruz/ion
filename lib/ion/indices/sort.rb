module Ion
class Indices::Sort < Ion::Index
  def index(record)
    value = value_for(record)
    value = transform(value)

    key_for(record).hset name, value
  end

  # The function that the string passes thru before going to the db.
  def transform(value)
    str = value.to_s.downcase.strip
    str = str[4..-1]  if str[0..3] == "the "  # Remove articles from sorting
    str
  end

  def self.deindex(record)
    key_for(record).del
  end

  def spec
    # Ion:sort:Album:*->title
    @spec ||= self.class.key[@options.model.name]["*->#{name}"]
  end

protected
  def self.key_for(record)
    # Ion:sort:Album:1
    key[record.class.name][record.id]
  end

  def self.key
    # Ion:sort
    Ion.key[:sort]
  end

  def key_for(record)
    self.class.key_for(record)
  end
end
end
