class Ion::Scope
  include Ion::Helpers

  attr_reader :parent
  attr_reader :search
  attr_reader :key

  def initialize(search, parent=nil)
    @search = search
    @parent = parent
    @key    = Ion.volatile_key
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
    key.zunionstore([key, subkey])  # any_of
    Ion.expire subkey
  end

  def options
    @search.options
  end

  def ids
    key.zrevrange 0, -1
  end

protected
  def done
    Ion.expire key
  end
end
