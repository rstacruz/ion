class Ion::Search
  include Enumerable

  attr_reader :options

  def initialize(options)
    @options = options
    @scope   = Ion::Scope.new(self)
  end

  # Returns the model.
  # @example
  #
  #   search = Album.ion.search { ... }
  #   assert search.model == Album
  #
  def model
    @options.model
  end

  def to_a
    ids.map &model
  end

  def each(&blk)
    to_a.each &blk
  end

  def ids
    @scope.ids
  end

  def size
    ids.size
  end

  def yieldie(&blk)
    @scope.yieldie &blk
  end

  def key
    @scope.key
  end

# Searching
  
protected
  # Interal: called when the `Model.ion.search { }` block is done
  def done
    @scope.send :done
  end
end
