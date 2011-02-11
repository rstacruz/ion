module Ion
class Indices::Metaphone < Indices::Text
  def index_words(str)
    words = ::Text::Metaphone.metaphone(str).strip.split(' ')
  end
end
end
