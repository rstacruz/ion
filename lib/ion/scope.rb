class Ion::Scope
  include Ion::Helpers

  attr_reader :parent
  attr_writer :key

  def initialize(search, args={})
    @search  = search
    @parent  = args[:parent]
    @subkeys = Array.new
    @gate    = args[:gate] || :all

    raise Error  unless [:all, :any].include?(@gate)
  end

  def any_of(&blk)
    subscope :gate => :any, &blk
  end

  def all_of(&blk)
    subscope :gate => :all, &blk
  end

  def key
    @key ||= Ion.volatile_key
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
    subkey = options.index(type, field).search(what)
    Ion.expire subkey
    @subkeys << subkey
  end

  def options
    @search.options
  end

  def ids
    key.zrevrange 0, -1
  end

protected
  def done
    if @subkeys.size == 1
      self.key = @subkeys.first
    elsif @subkeys.size > 1
      combine @subkeys
    end
    Ion.expire key # OPT: make sure this is only done once
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
    scope = Ion::Scope.new(@search, { :parent => self }.merge(args))
    scope.yieldie &blk
    scope.done
    @subkeys << scope.key
  end
end
