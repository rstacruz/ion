module Ion::Scope::Hash
  def to_hash
    h = ::Hash.new
    h['gate'] = @gate.to_s  unless @gate == :all
    h['score'] = @score.to_f  unless @score == 1.0
    h['scopes'] = scopes.map(&:to_hash)  if scopes.any?
    h['searches'] = searches.map { |(index, (what, args))|
      hh = ::Hash.new
      hh['index'] = index.to_hash
      hh['value'] = what
      hh['args'] = args.to_hash  unless args.empty?
      hh
    }  if searches.any?
    h['boosts'] = boosts.map { |(scope, amount)| { 'scope' => scope.to_hash, 'amount' => amount.to_f } }  if boosts.any?
    h
  end

  def to_s
    a, b = Array.new, Array.new
    sep = (@gate == :any) ? ' | ' : ' & '

    a += searches.map { |(ix, (what, _))| "#{ix.name}.#{ix.type}:\"#{what.gsub('"', '\"')}\"" }
    a += scopes.map { |scope| "(#{scope})" }

    b << a.join(sep)  if a.any?
    b << "*#{@score}"  if @score != 1.0
    b += boosts.map { |(scope, amount)| "(#{scope} +*#{amount})" }

    b.join(' ')
  end

  # Unpack the given hash.
  def deserialize(args)
    if args['searches']
      args['searches'].each do |h|
        index = h['index']
        search index['type'].to_sym, index['name'].to_sym, h['value']
      end
    end

    if args['scopes']
      args['scopes'].each { |h| scopes << subscope(h) }
    end

    if args['boosts']
      args['boosts'].each do |h|
        boost h['amount'], h['scope']
      end
    end
  end
end
