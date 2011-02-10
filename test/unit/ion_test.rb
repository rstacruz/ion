# ==============================================================================
# Sample
require 'test_helper'

module IT; end

class IT::Album < Ohm::Model
  include Ion::Entity
  include Ohm::Callbacks

  attribute :title
  attribute :body

  ion {
    text :title
    text :body
  }

  after :save, :update_ion_indices
end

Album = IT::Album

class IonTest < Test::Unit::TestCase
  setup do
    # Fake entries that should NOT be returned
    10.times { Album.create title: Faker::Company.bs, body: '' }
  end

  test "single result" do
    @album = Album.create title: "Vloop", body: "Secher Betrib"
    search = Album.ion.search { keywords "Vloop" }

    assert_equal 1, search.results.size
    assert_equal @album.id, search.results.first.id
  end

  test "stripping punctuations" do
    @album = Album.create title: "Vloop", body: "Les faux-tambros rafalo."
    search = Album.ion.search { keywords "faux rafalo" }

    assert_equal 1, search.results.size
    assert_equal @album.id, search.results.first.id
  end

  test "many results" do
    albums = (0..10).map {
      Album.create title: "Yo " + Faker::Company.bs, body: "Moshen Kashkan"
    }

    search = Album.ion.search { keywords "Yo" }
    ids    = search.results.map(&:id).sort

    assert_equal albums.size, search.results.size
    assert_equal albums.map(&:id).sort, ids
  end

  test "multi keywords" do
    @album = Album.create title: "Krambos chortluus"

    search = Album.ion.search { keywords "krambos chortluus" }
    ids    = search.results.map(&:id).sort

    assert_equal [@album.id], ids
  end

  test "search with arity" do
    @album = Album.create title: "Shifah loknom"

    search = Album.ion.search { |q| q.keywords "shifah loknom" }
    ids = search.results.map(&:id).sort

    assert_equal [@album.id], ids
  end

  test "with" do
    return #pending
    @album1 = Album.create title: "Hey there you", body: "Yes you"
    @album2 = Album.create title: "Yes there it is", body: "Haha"

    search = Album.ion.search { keywords "yes", in: :title }
    ids    = search.results.map(&:id).sort
  end
end
