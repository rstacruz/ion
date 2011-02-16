class Ion::Scope
  include Ion::Helpers

  def initialize(search, args={}, &blk)
    @search  = search
    @gate    = args[:gate]  || :all
    @score   = args[:score] || 1.0
    @type    = :z # or :l

    raise Ion::Error  unless [:all, :any].include?(@gate)
    yieldie(&blk)  if block_given?
  end

  def any_of(&blk)
    scopes << subscope(:gate => :any, &blk)
  end

  def all_of(&blk)
    scopes << subscope(:gate => :all, &blk)
  end

  def boost(amount=1.0, &blk)
    boosts << [Ion::Scope.new(@search, :gate => :all, &blk), amount]
  end

  def score(score, &blk)
    scopes << subscope(:score => score, &blk)
  end

  def key
    @key ||= get_key
  end

  def sort_by(what)
    key
    index = @search.options.index(:sort, what)
    key.sort by: index.spec, order: "ASC ALPHA", store: key
  end

  # Only when done
  def count
    key
    return key.zcard  if key.type == "zset"
    return key.llen   if key.type == "list"
    0
  end

  # Defines the shortcuts `text :foo 'xyz'` => `search :text, :foo, 'xyz'`
  Ion::Indices.names.each do |type|
    define_method(type) do |field, what, args={}|
      search type, field, what, args
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
    searches << [ options.index(type, field), [what, args] ]
  end

  def options
    @search.options
  end

  def ids(range)
    key

    from, to = range.first, range.last
    to -= 1  if range.exclude_end?
    
    type = key.type
    results = if type == "zset"
        key.zrevrange(from, to) 
      elsif type == "list"
        key.lrange(from, to)
      else
        Array.new
      end

    expire and results
  end

protected
  # List of scopes to be cleaned up after. (Array of Scope instances)
  def scopes()     @scopes ||= Array.new end

  # List of keys (like search keys) to be cleaned up after.
  def temp_keys()  @temp_keys ||= Array.new end

  # List of boost scopes -- [Scope, amount] tuples
  def boosts()     @boosts ||= Array.new end

  def searches()   @searches ||= Array.new end

  def get_key
    # Wrap up it's subscopes
    scope_keys = scopes.map(&:key)

    # Wrap up the searches
    search_keys = searches.map { |(index, args)| index.search(*args) }
    @temp_keys = search_keys

    # Intersect or union all the subkeys
    key = combine(scope_keys + search_keys)

    # Adjust scores accordingly
    key = rescore(key, @score)  if @score != 1.0 && !key.nil?

    # Don't proceed if there are no results anyway
    return Ion.volatile_key  if key.nil?

    # Process boosts
    boosts.each do |(scope, amount)|
      inter = Ion.volatile_key
      inter.zinterstore [key, scope.key], :weights => [amount, 0]
      key.zunionstore [key, inter], :aggregate => (amount > 1 ? :max : :min)
      @temp_keys << inter
    end

    key
  end

  def rescore(key, score)
    dest = key.include?('~') ? key : Ion.volatile_key
    dest.zunionstore([key], weights: score)
    dest
  end

  # Sets the TTL for the temp keys.
  def expire
    scopes.each { |s| s.send :expire }
    Ion.expire key, *temp_keys
  end

  def combine(subkeys)
    return nil  if subkeys.empty?
    return subkeys.first  if subkeys.size == 1

    _key = Ion.volatile_key
    if @gate == :all
      _key.zinterstore subkeys
    elsif @gate == :any
      _key.zunionstore subkeys
    end

    _key
  end

  # Used by all_of and any_of
  def subscope(args={}, &blk)
    opts  = { :gate => @gate, :score => @score }
    Ion::Scope.new(@search, opts.merge(args), &blk)
  end
end
