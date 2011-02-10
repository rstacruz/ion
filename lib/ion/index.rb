class Ion::Index
  attr_reader :name
  attr_reader :options

  def initialize(name, options, extra={})
    @name    = name
    @options = options
  end

  def index(record)
  end

  # Returns a key (set) of results
  def search(search)
  end
end
