require 'test_helper'

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
    search = Album.ion.search { text :title, "Vloop" }

    assert_equal 1, search.size
    assert_equal @album.id, search.first.id
  end

  test "stripping punctuations" do
    @album = Album.create title: "Vloop", body: "Les faux-tambros rafalo."
    search = Album.ion.search { text :body, "faux rafalo" }

    assert_equal 1, search.size
    assert_equal @album.id, search.first.id
  end

  test "many results" do
    albums = (0..10).map {
      Album.create title: "Yo " + Faker::Company.bs, body: "Moshen Kashkan"
    }

    search = Album.ion.search { text :title, "Yo" }

    assert_equal albums.size, search.size
    assert_equal albums.map(&:id).sort, search.ids.sort
  end

  test "multi keywords" do
    @album = Album.create title: "Callay Krambos Chortluus secher glibbet"
    search = Album.ion.search { text :title, "krambos chortluus" }

    assert_equal [@album.id], search.ids.sort
  end

  test "multi keywords fail" do
    @album = Album.create title: "Krambos chortluus"
    search = Album.ion.search { text :title, "krambos lol" }

    assert_equal [], search.ids.sort
  end

  test "search with arity" do
    @album = Album.create title: "Shifah loknom"
    search = Album.ion.search { |q| q.text :title, "shifah loknom" }

    assert_equal [@album.id], search.ids.sort
  end

  test "with" do
    return #pending
    @album1 = Album.create title: "Hey there you", body: "Yes you"
    @album2 = Album.create title: "Yes there it is", body: "Haha"

    search = Album.ion.search { text :title, "yes" }
  end
end
