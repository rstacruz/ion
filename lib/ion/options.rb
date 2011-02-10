class Ion::Options
  attr_reader :model
  attr_reader :indices

  def initialize(model)
    @model = model
    @indices = Hash.new
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

protected
  def text(id, options={})
    field :text, id, options
  end

  def field(type, id, options={})
    @indices[id.to_sym] = Ion::Indices::Text.new(id, self, options)
  end
end

