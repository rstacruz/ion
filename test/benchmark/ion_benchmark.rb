class IonMark < BM
  setup
  size = 5000

  measure "Searching - one word", size do
    size.times {
      phrase = 'lorem'
      Album.ion.search {
        text :title, phrase
      }.ids
    }
  end

  measure "Searching - three words", size do
    size.times {
      phrase = 'lorem ipsum dolor'
      Album.ion.search {
        text :title, phrase
      }.ids
    }
  end

  measure "Searching - 2 fields", size do
    size.times {
      phrase = 'lorem'
      Album.ion.search {
        text :title, phrase
        text :body,  phrase
      }.ids
    }
  end
end
