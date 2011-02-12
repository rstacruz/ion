class Ion::Scope
  include Ion::Helpers

  attr_reader :parent
  attr_reader :search
  attr_reader :key

  def initialize(search, parent=nil)
    @search  = search
    @parent  = parent
    @key     = Ion.volatile_key
    @subkeys = Array.new
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
      @key = @subkeys.first      # Use the key as is
    elsif @subkeys.size > 1
      key.zunionstore @subkeys   # Combine the keys
    end
    Ion.expire key
  end
end
