class Ion::Scope
  include Ion::Helpers

  attr_reader :parent
  attr_reader :scopes
  attr_writer :key

  def initialize(search, args={}, &blk)
    @search  = search
    @parent  = args[:parent]
    @subkeys = Array.new
    @scopes  = Array.new
    @searchkeys = Array.new
    @gate    = args[:gate] || :all
    @score   = args[:score] || 1.0

    run(&blk)  if block_given?
    raise Ion::Error  unless [:all, :any].include?(@gate)
  end

  def any_of(&blk)
    @scopes << subscope(:gate => :any, &blk)
  end

  def all_of(&blk)
    @scopes << subscope(:gate => :all, &blk)
  end

  def score(score, &blk)
    @scopes << subscope(:score => (score * @score), &blk)
  end

  def key
    @key ||= Ion.volatile_key
  end

  def count
    ids.count
  end

  # Defines the shortcuts `text :foo 'xyz'` => `search :text, :foo, 'xyz'`
  Ion::Indices.names.each do |type|
    define_method(type) do |field, what, args={}|
      search type, field, what, { :score => @score }.merge(args)
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
  def search(type, field, what, args={})
    subkey = options.index(type, field).search(what, args)
    @searchkeys << subkey
    @subkeys    << subkey
  end

  def options
    @search.options
  end

  def ids
    results = key.zrevrange(0, -1)
    expire
    results
  end

protected
  def done
    if @subkeys.size == 1
      self.key = @subkeys.first
    elsif @subkeys.size > 1
      combine @subkeys
    end
  end

  # Sets the TTL for the temp keys.
  def expire
    @scopes.each { |s| s.send :expire }
    Ion.expire key, *@searchkeys
  end

  def combine(subkeys)
    if @gate == :all
      key.zinterstore subkeys
    elsif @gate == :any
      key.zunionstore subkeys
    end
  end

  # Used by all_of and any_of
  def subscope(args={}, &blk)
    opts = {
      :parent => self,
      :gate => @gate,
      :score => @score
    }
    scope = Ion::Scope.new(@search, opts.merge(args), &blk)
    key   = scope.key
    @subkeys << scope.key
    scope
  end

  # Runs a given DSL block.
  def run(&blk)
    yieldie(&blk) and done
  end
end
