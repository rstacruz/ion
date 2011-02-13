class IonMark < BM
  setup

  size = Album.all.size
  measure "Indexing", size do
    Album.all.each { |a| a.update_ion_indices }
  end

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
