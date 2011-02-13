class Nest
  def zlist
    Hash[*zrange(0, -1, with_scores: true)]
  end
end

def k
  Ion.key
end
