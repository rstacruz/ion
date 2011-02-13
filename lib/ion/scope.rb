class Ion::Scope
  include Ion::Helpers

  attr_writer :key

  def initialize(search, args={}, &blk)
    @search  = search
    @gate    = args[:gate]  || :all
    @score   = args[:score] || 1.0
    @type    = :z # or :l

    yieldie(&blk) and done  if block_given?

    raise Ion::Error  unless [:all, :any].include?(@gate)
  end

  # Returns a unique hash of what the scope contains.
  def search_hash
    @search_hash ||= [[@gate, @score]]
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
    @key ||= Ion.volatile_key
  end

  def sort_by(what)
    index = @search.options.index(:sort, what)
    key.sort by: index.spec, order: "ASC ALPHA", store: key
  end

  # Only when done
  def count
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
    subkey = options.index(type, field).search(what, args)
    temp_keys   << subkey
    subkeys     << subkey
    search_hash << [type,field,what,args]
  end

  def options
    @search.options
  end

  def ids(range)
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

  # List of keys that contain results to be combined.
  def subkeys()    @subkeys ||= Array.new end

  # List of keys (like search keys) to be cleaned up after.
  def temp_keys()  @temp_keys ||= Array.new end

  # List of boost scopes -- [Scope, amount] tuples
  def boosts()     @boosts ||= Array.new end

  # Called by #run after doing an instance_eval of DSL stuff.
  # This consolidates the keys into self.key.
  def done
    if subkeys.size == 1
      self.key = subkeys.first
    elsif subkeys.size > 1
      combine subkeys
    end

    # Adjust scores accordingly
    self.key = rescore(key, @score)

    boosts.each do |(scope, amount)|
      inter = Ion.volatile_key
      inter.zinterstore [key, scope.key], :weights => [amount, 0]
      key.zunionstore [key, inter], :aggregate => (amount > 1 ? :max : :min)
      temp_keys << inter
    end
  end

  def rescore(key, score)
    return key  if score == 1.0
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
    if @gate == :all
      key.zinterstore subkeys
    elsif @gate == :any
      key.zunionstore subkeys
    end
  end

  # Used by all_of and any_of
  def subscope(args={}, &blk)
    opts  = { :gate => @gate, :score => @score }
    scope = Ion::Scope.new(@search, opts.merge(args), &blk)

    subkeys     << scope.key
    search_hash << scope.search_hash
    scope
  end
end
