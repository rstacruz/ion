require_relative '../test_helper'

class IonTest < Test::Unit::TestCase
  setup do
    # Fake entries that should NOT be returned
    5.times { Album.create title: lorem, body: '' }
  end

  test "single result" do
    item   = Album.create title: "First Lady of Song", body: "Ella Fitzgerald"
    search = Album.ion.search { text :title, "lady" }

    assert_equal [item.id], search.ids
  end

  test "lambda index" do
    item   = Album.create title: "First Lady of Song", body: "Ella Fitzgerald"
    search = Album.ion.search { text :also_title, "lady" }

    assert_equal [item.id], search.ids
  end

  test "stripping punctuations" do
    item   = Album.create title: "Leapin-and-Lopin'"
    search = Album.ion.search { text :title, "leapin lopin" }

    assert_equal [item.id], search.ids
  end

  test "many results" do
    albums = (0..10).map {
      Album.create title: "Hi #{lorem}"
    }

    search = Album.ion.search { text :title, "Hi" }

    assert_equal albums.size, search.size
    assert_equal albums.map(&:id).sort, search.ids.sort
  end

  test "multi keywords" do
    album  = Album.create title: "Mingus at the Bohemia"
    search = Album.ion.search { text :title, "mingus bohemia" }

    assert_equal [album.id], search.ids.sort
  end

  test "multi keywords fail" do
    album  = Album.create title: "Mingus at the Bohemia"
    search = Album.ion.search { text :title, "bohemia is it" }

    assert_equal [], search.ids.sort
  end

  test "search with arity" do
    item   = Album.create title: "Maiden Voyage"
    search = Album.ion.search { |q| q.text :title, "maiden voyage" }

    assert_equal [item.id], search.ids.sort
  end

  test "search within one index only" do
    album1 = Album.create title: "Future 2 Future", body: "Herbie Hancock"
    album2 = Album.create title: "Best of Herbie", body: "VA"

    search = Album.ion.search { text :title, "herbie" }

    assert_equal [album2.id], search.ids.sort
  end

  test "count" do
    5.times { Album.create(title: "Bebel Gilberto #{lorem}") }

    search = Album.ion.search { text :title, "Bebel Gilberto" }
    assert_equal 5, search.count
  end

  test "scores" do
    @items = {
      a: Album.create(title: "Future 2 Future", body: "Herbie Hancock"),
      b: Album.create(title: "Best of Herbie", body: "Herbie Hancock")
    }

    search = Album.ion.search {
      any_of {
        text :title, "herbie"
        text :body,  "herbie"
      }
    }

    # Album2 will go first because it matches both
    assert_ids %w(a b), for: search

    # Check if the scores are right
    scores = scores_for search
    assert_equal "2", scores[@items[:b].id]
    assert_equal "1", scores[@items[:a].id]
  end
end
