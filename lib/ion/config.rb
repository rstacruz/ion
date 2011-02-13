class Ion::Config < OpenStruct
  def initialize(args={})
    super defaults.merge(args)
  end

  def defaults
    @defaults ||= {
      :ignored_words => %w(a it at the)
    }
  end

  def method_missing(meth, *args, &blk)
    return @table.keys.include?(meth[0...-1].to_sym)  if meth.to_s[-1] == '?'
    super
  end
end
