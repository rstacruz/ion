# ==============================================================================
# Sample
require 'test_helper'

class Album < Ohm::Model
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


class IonTest < Test::Unit::TestCase
  setup do
    # Fake entries that should NOT be returned
    10.times { Album.create title: Faker::Company.bs, body: '' }
  end

  test "foo" do
    @album = Album.create title: "Vloop", body: "Secher Betrib"
    search = Album.ion.search { keywords "Vloop" }

    assert_equal 1, search.results.size
    assert_equal @album.id, search.results.first.id
  end

  test "many" do
    albums = (0..10).map {
      Album.create title: "Yo " + Faker::Company.bs, body: "Moshen Kashkan"
    }
    search = Album.ion.search { keywords "Yo" }

    assert_equal albums.size, search.results.size

    ids = search.results.map(&:id).sort

    albums.each do |album|
      assert ids.include?(album.id)
    end
  end

  test "multi" do
    @album = Album.create title: "Hey there you"
    search = Album.ion.search { keywords "Hey there you" }

    ids = search.results.map(&:id).sort
    assert_equal [@album.id], ids
  end

  test "search with arity" do
    @album = Album.create title: "Hey there you"
    search = Album.ion.search { |q| q.keywords "Hey there you" }

    ids = search.results.map(&:id).sort
    assert_equal [@album.id], ids
  end

  test "with" do
    return #pending
    @album1 = Album.create title: "Hey there you", body: "Yes you"
    @album2 = Album.create title: "Yes there it is", body: "Haha"
    search = Album.ion.search { with :title, "yes" }
  end
end
