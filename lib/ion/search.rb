class Ion::Search
  include Enumerable

  attr_reader :key

  def initialize(options)
    @options = options
    @key     = Ion.volatile_key
    @gate    = :any # or :all
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
    ids.map &(@options.model)
  end

  def each(&blk)
    to_a.each &blk
  end

  def ids
    @key.smembers
  end

  def size
    ids.size
  end

# Searching
  
  # TODO: make tests for this first
  # def any_of(&blk)
  #   old, @gate = @gate, :any
  #   self.instance_eval &blk
  #   @gate = old
  # end

  # def all_of(&blk)
  #   old, @gate = @gate, :all
  #   self.instance_eval &blk
  #   @gate = old
  # end
  
  [:text].each do |type|
    define_method(type) do |field, what, options={}|
      search type, field, what, options
    end
  end

  # Searches a given field.
  # @example
  #   class Album
  #     ion { text :name }
  #   end
  #
  #   Album.ion.search {
  #     search :text, :name, "Emotional Technology"
  #     text :name, "Emotional Technology"   # same
  #   }
  def search(type, field, what, options={})
    key = @options.index(type, field).search(what)
    @key.sunionstore(@results, key)  # any_of
  end
end
