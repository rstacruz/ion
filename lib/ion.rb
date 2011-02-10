require 'redis'
require 'nest'

module Ion
  def self.key
    @key ||= Nest.new('Ion')
  end
end

module Ion::Stringer
  def self.sanitize(str)
    return ''  unless str.is_a?(String)
    str.downcase.force_encoding('UTF-8')
  end

  # "Hey,  yes you." => %w(hey yes you)
  def self.keywords(str)
    return Array.new  unless str.is_a?(String)
    self.sanitize(str).scan(/\w+/)
  end
end

# ==============================================================================
class Ion::Options
  attr_reader :model
  attr_reader :fields

  def initialize(model)
    @model = model
    @fields = Hash.new
  end

  def search(&blk)
    search = Ion::Search.new(self)
    search.instance_eval(&blk)  if block_given?
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
    @fields[id.to_sym] = options
  end
end

# ==============================================================================
class Ion::Search
  def initialize(options)
    @options = options
  end

  def keywords(keywords=nil)
    @keywords ||= ''
    @keywords = keywords  unless keywords.nil?
    @keywords
  end

  def results
    words = Ion::Stringer.keywords(@keywords)
    results = Array.new

    fields = [:title] #stub
    fields.each do |field|
      key = @options.key[:keywords][field]
      words.each do |word|
        ids = key[word].smembers
        results += ids  unless ids.nil?
      end
    end

    results.uniq.map(&(@options.model))
  end

  def to_a
    results
  end

  def size
    results.size
  end
end

# ==============================================================================
module Ion::Entity
  def self.included(to)
    to.extend ClassMethods
  end

  def update_ion_indices
    # Call me after saving
    ion = self.class.ion
    key = ion.key
    id  = self.id

    ion.fields.each do |name, field|
      value    = self.send(name)
      keywords = Ion::Stringer.keywords(value)
      keywords.each do |word|
        key[:keywords][name][word].sadd id
      end
    end
  end

  module ClassMethods
    def ion(&blk)
      @ion_options ||= Ion::Options.new(self)
      @ion_options.instance_eval(&blk)  if block_given?
      @ion_options
    end
  end
end

# Ion:MODEL:keywords:FIELD:word
