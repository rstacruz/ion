require_relative '../test_helper'

class IonTest < Test::Unit::TestCase
  setup do
    # Fake entries that should NOT be returned
    10.times { Album.create title: Faker::Company.bs, body: '' }
  end

  test "single result" do
    item   = Album.create title: "Vloop", body: "Secher Betrib"
    search = Album.ion.search { text :title, "Vloop" }

    assert_equal [item.id], search.ids
  end

  test "lambda index" do
    item   = Album.create title: "Vloop", body: "Secher Betrib"
    search = Album.ion.search { text :also_title, "Vloop" }

    assert_equal [item.id], search.ids
  end

  test "stripping punctuations" do
    item   = Album.create title: "Minxx", body: "Les faux-tambros rafalo."
    search = Album.ion.search { text :body, "faux rafalo" }

    assert_equal [item.id], search.ids
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
    album  = Album.create title: "Callay Krambos Chortluus secher glibbet"
    search = Album.ion.search { text :title, "krambos chortluus" }

    assert_equal [album.id], search.ids.sort
  end

  test "multi keywords fail" do
    album  = Album.create title: "Krambos chortluus"
    search = Album.ion.search { text :title, "krambos lol" }

    assert_equal [], search.ids.sort
  end

  test "search with arity" do
    item   = Album.create title: "Shifah loknom"
    search = Album.ion.search { |q| q.text :title, "shifah loknom" }

    assert_equal [item.id], search.ids.sort
  end

  test "search within one index only" do
    album1 = Album.create title: "Hey there you", body: "Yes you"
    album2 = Album.create title: "Yes there it is", body: "Haha"

    search = Album.ion.search { text :title, "yes" }

    assert_equal [album2.id], search.ids.sort
  end

  test "count" do
    10.times { Album.create(title: "Quod libet #{phrase}") }

    search = Album.ion.search { text :title, "quod" }
    assert_equal 10, search.count
  end

  test "scores" do
    album1 = Album.create title: "Yes there it is", body: "Haha"
    album2 = Album.create title: "Yes yeah", body: "Yes you"

    search = Album.ion.search {
      any_of {
        text :title, "yes"
        text :body,  "yes"
      }
    }

    # Album2 will go first because it matches both
    assert_equal [album2.id, album1.id], search.ids

    # Check if the scores are right
    scores = Hash[*search.key.zrevrange(0, -1, with_scores: true)]
    assert_equal "2", scores[album2.id]
    assert_equal "1", scores[album1.id]
  end
end
