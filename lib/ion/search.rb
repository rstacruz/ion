class Ion::Search
  include Enumerable

  attr_reader :options
  attr_reader :scope

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

  def range(args=nil)
    @range = if args == :all
        nil
      elsif args.is_a?(Range)
        args
      elsif !args.is_a?(Hash)
        @range
      elsif args[:from] && args[:limit]
        ((args[:from]-1)..(args[:from]-1 + args[:limit]-1))
      elsif args[:page] && args[:limit]
        (((args[:page]-1)*args[:limit])..((args[:page])*args[:limit]))
      elsif args[:from] && args[:to]
        ((args[:from]-1)..(args[:to]-1))
      elsif args[:from]
        ((args[:from]-1)..-1)
      else
        @range
      end || (0..-1)
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

  def sort_by(what)
    @scope.sort_by what
  end

  def ids
    @scope.ids range
  end

  def key
    @scope.key
  end

  def to_hash
    @scope.to_hash
  end

# Searching
  
protected
  # Interal: called when the `Model.ion.search { }` block is done
  def done
    @scope.send :done
  end
end
