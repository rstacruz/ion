require_relative '../test_helper'

class RangeTest < Test::Unit::TestCase
  setup do
    # Fake entries that should NOT be returned
    5.times { Album.create title: lorem, body: '' }

    @items = {
      :a => Album.create(title: "X Morning Scifi"),
      :b => Album.create(title: "X Intensify", body: 'Special Edition'),
      :c => Album.create(title: "X BT Emotional Technology", body: 'Special Edition'),
      :d => Album.create(title: "X BT Movement in Still Life"),
      :e => Album.create(title: "X Involver"),
      :f => Album.create(title: "X Bullet"),
      :g => Album.create(title: "X Fear of a Silver Planet"),
      :h => Album.create(title: "X Renaissance: Everybody")
    }
  end

  test "ranges" do
    search = Album.ion.search { text :title, 'x' }
    ids = search.ids

    search.range from: 2, limit: 1

    assert_equal (1..1), search.range
    assert_equal ids[1..1], search.ids

    search.range from: 4, to: 4
    assert_equal (3..3), search.range
    assert_equal ids[3..3], search.ids

    search.range from: 1, to: 3
    assert_equal (0..2), search.range
    assert_equal ids[0..2], search.ids

    search.range (3..4)
    assert_equal (3..4), search.range
    assert_equal ids[3..4], search.ids

    search.range (3..-1)
    assert_equal (3..-1), search.range
    assert_equal ids[3..-1], search.ids

    search.range (3..-3)
    assert_equal (3..-3), search.range
    assert_equal ids[3..-3], search.ids

    search.range (3...4)
    assert_equal (3...4), search.range
    assert_equal ids[3...4], search.ids

    search.range (3...-1)
    assert_equal (3...-1), search.range
    assert_equal ids[3...-1], search.ids

    search.range :all
    assert_equal (0..-1), search.range
    assert_equal ids, search.ids
  end

  test "iterating through ranges" do
    search = Album.ion.search { text :title, 'x' }
    ids = search.ids
    search.range from: 2, limit: 4

    assert_equal 4, search.ids.size
    assert_equal 8, search.size

    injected = search.inject(0) { |i, _| i += 1 }
    assert_equal 4, injected

    mapped = search.map { 1 }
    assert_equal [1,1,1,1], mapped
  end
end
