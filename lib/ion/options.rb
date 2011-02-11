class Ion::Options
  attr_reader :model

  def initialize(model)
    @model = model
    @indices = Hash.new { |h, k| h[k] = Hash.new }
  end

  def search(&blk)
    search = Ion::Search.new(self)
    if block_given?
      if blk.arity == 0
        search.instance_eval(&blk)
      else
        blk.yield(search)
      end
    end
    search
  end


  def key
    @key ||= Ion.key[model.name]  #=> 'Ion:Person'
  end

  # Returns a certain index.
  # @example
  #   @options.index(:text, :title)
  def index(type, name)
    @indices[type][name]
  end

  # Returns all indices.
  def indices
    @indices.values.map(&:values).flatten
  end

protected
  def text(id, options={})
    field :text, id, options
  end

  def field(type, id, options={})
    index_type = Ion::Indices.get(type)
    @indices[type][id.to_sym] = index_type.new(id, self, options)
  end
end

