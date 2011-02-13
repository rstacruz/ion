require_relative '../test_helper'

class SortTest < Test::Unit::TestCase
  setup do
    # Fake entries that should NOT be returned
    5.times { Album.create title: lorem, body: '' }

    @items = {
      :r1 => Album.create(title: "Eurostile x"),
      :r2 => Album.create(title: "Garamond x"),
      :r3 => Album.create(title: "Didot x"),
      :r4 => Album.create(title: "Caslon x"),
      :r5 => Album.create(title: "Avenir x"),
      :r6 => Album.create(title: "The Bodoni x"),
      :r7 => Album.create(title: "Helvetica x"),
      :r8 => Album.create(title: "Futura x")
    }

    @search = Album.ion.search { text :title, 'x' }
    @search.sort_by :title
  end

  test "sort" do
    assert_ids %w(r5 r6 r4 r3 r1 r8 r2 r7), for: @search, ordered: true
  end

  test "range 1" do
    @search.range from: 1, limit: 4
    assert_ids %w(r5 r6 r4 r3), for: @search, ordered: true
  end

  test "range 2" do
    @search.range from: 2, limit: 4
    assert_ids %w(r6 r4 r3 r1), for: @search, ordered: true
  end
end
