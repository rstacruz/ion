require File.expand_path('../../benchmark_helper', __FILE__)

class IonMark < BM
  setup
  size = Album.all.size
  measure "Indexing", size do
    Album.all.each { |a| a.update_ion_indices }
  end
end
