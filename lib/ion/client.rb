require 'json'
require 'restclient'

# Note: this class aims to be decoupled from the rest of Ion,
# so don't go making things like "model[id].ion" or something
# like that.
class Ion::Client
  Error = Class.new(StandardError)

  attr_reader :error

  def initialize(options={})
    @base_uri = options.delete(:url) || ENV['ION_URL'] || 'http://127.0.0.1:8082'
  end

  def ok?
    @ok.nil? || @ok
  end

  # Returns version info.
  #
  # @example
  #   a = client.about
  #   assert a.app == "Ion"
  #   assert a.version >= "1.0"
  #
  def about
    get '/about'
  end

  # Defines the indices for a given model.
  #
  # @example
  #   client.define Album, Album.ion.to_hash # { 'indices' => [ ... ] }
  #
  def define(model, options)
    post "/index/#{model}", :body => options.to_hash.to_json
  end

  # Searches.
  # Define must be ran first.
  #
  # @example
  #   search = Album.ion.search { ... }
  #   client.search Album, search.to_hash
  #
  def search(model, search)
    get "/search/#{model}", :body => search.to_hash.to_json
  end

  # Deindexes a model.
  def del(model, id)
    request :delete, "/index/#{model}/#{id}"
  end

  # Indexes a model.
  # 
  # @example
  #   item = Album[1]
  #   hash = Album.ion.index_hash(item)   # Under debate
  #   client.index Album, item.id, hash
  #
  def index(model, id, options)
    request :post, "/index/#{model}/#{id}", :body => options.to_hash.to_json
  end

protected
  def get(url, params={})
    request :get, url, :params => params, :accept => :json
  end

  def post(url, params={})
    request :post, url, params#, :content_type => :json, :accept => :json
  end

  # Sends a request
  def request(meth, url, *a)
    RestClient.send(meth, "#{@base_uri}#{url}", *a, &method(:handle))
  end

  # Response handler
  def handle(response, request, result, &blk)
    hash = JSON.parse(response)
    os   = OpenStruct.new(hash)
    @ok  = false

    case response.code
    when 200
      @ok = true; @error = nil
      return os
    when 400 # Error
      @error = os
    when 500 # Internal server error
      @error = OpenStruct.new(:message => "Internal server error")
    end
  rescue JSON::ParserError
    @error = OpenStruct.new(:message => "JSON parse error")
  end

end

