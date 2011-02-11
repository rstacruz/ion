class Ion::Index
  attr_reader :name
  attr_reader :options

  def initialize(name, options, extra={})
    @name    = name
    @options = options
  end

  # Indexes a record
  def index(record)
  end

  # Returns a key (set) of results
  def search(what)
  end

protected

  # Returns the value for a certain record
  def value_for(record)
    record.send name
  end

  # Returns the index key
  # Example: Ion:Album:text:title
  def index_key
    @class_name ||= self.class.name.split(':').last.downcase
    @options.key[@class_name][self.name]
  end
end
