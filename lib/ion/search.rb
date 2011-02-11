class Ion::Search
  include Enumerable
  include Ion::Helpers

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
    ids.map &model
  end

  def each(&blk)
    to_a.each &blk
  end

  def ids
    @key.zrevrange 0, -1
  end

  def size
    ids.size
  end

# Searching
  
  # TODO: make tests for this first
  # def any_of(&blk)
  #   old, @gate = @gate, :any
  #   yieldie &blk
  #   @gate = old
  # end

  # def all_of(&blk)
  #   old, @gate = @gate, :all
  #   yieldie &blk
  #   @gate = old
  # end

  # Defines the shortcuts `text :foo 'xyz'` => `search :text, :foo, 'xyz'`
  Ion::Indices.names.each do |type|
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
    subkey = @options.index(type, field).search(what)
    @key.zunionstore([@key, subkey])  # any_of
    Ion.expire subkey
  end

protected
  # Interal: called when the `Model.ion.search { }` block is done
  def done
    Ion.expire @key
  end
end
