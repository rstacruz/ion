class Ion::Config < OpenStruct
  def initialize(args={})
    super defaults.merge(args)
  end

  def defaults
    @defaults ||= {
      :stopwords => %w(a an and are as at be but by for if in into is) +
                    %w(it no not of on or s such t that the their then) +
                    %w(there these they this to was will with)
    }
  end

  def method_missing(meth, *args, &blk)
    return @table.keys.include?(meth[0...-1].to_sym)  if meth.to_s[-1] == '?'
    super
  end
end
