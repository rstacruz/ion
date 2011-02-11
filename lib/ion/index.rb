class Ion::Index
  attr_reader :name
  attr_reader :options

  def initialize(name, options, extra={}, &blk)
    @name    = name
    @options = options
    @lambda  = blk  if block_given?
    @lambda  ||= Proc.new { self.send(name) }
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
    record.instance_eval &@lambda
  end

  # Returns the index key
  # Example: Ion:Album:text:title
  def index_key
    @class_name ||= self.class.name.split(':').last.downcase
    @options.key[@class_name][self.name]
  end
end
