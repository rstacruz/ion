class Ion::Search
  include Enumerable

  attr_reader :options

  def initialize(options, &blk)
    @options = options
    @scope   = Ion::Scope.new(self, &blk)
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

  def size
    @scope.count
  end

  def yieldie(&blk)
    @scope.yieldie &blk
  end

  def ids
    @scope.ids
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
