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
end
