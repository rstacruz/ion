class Ion::Options
  attr_reader :model

  def initialize(model, options={})
    @model = model
    @indices = Hash.new { |h, k| h[k] = Hash.new }

    # deserialize
    if options['indices']
      options['indices'].each { |h| field h['type'], h['name'] }
    end
  end

  def search(spec=nil, &blk)
    Ion::Search.new(self, spec, &blk)
  end

  def key
    @key ||= Ion.key[model.name]  #=> 'Ion:Person'
  end

  # Returns a certain index.
  # @example
  #   @options.index(:text, :title) #=> <#Ion::Indices::Text>
  def index(type, name)
    @indices[type.to_sym][name.to_sym]
  end

  # Returns all indices.
  def indices
    @indices.values.map(&:values).flatten
  end

  def index_types
    indices.map(&:class).uniq
  end

  def to_hash
    { 'indices' => indices.map { |ix| ix.to_hash } }
  end

protected
  # Creates the shortcuts `text :foo` => `field :text, :foo`
  Ion::Indices.names.each do |type|
    define_method(type) do |id, options={}, &blk|
      field type, id, options, &blk
    end
  end

  def field(type, id, options={}, &blk)
    index_type = Ion::Indices.get(type)
    @indices[type.to_sym][id.to_sym] = index_type.new(id.to_sym, self, options, &blk)
  end
end

