require_relative '../test_helper'

class Number < Test::Unit::TestCase
  setup do
    @items = {
      :a => Album.create(play_count: 1),
      :b => Album.create(play_count: 2),
      :c => Album.create(play_count: 3),
      :d => Album.create(play_count: 4),
      :e => Album.create(play_count: 4),
      :f => Album.create(play_count: 4),
      :g => Album.create(play_count: 5),
      :h => Album.create(play_count: 5)
    }
  end

  test "numb3rs" do
    search = Album.ion.search { number :play_count, 4 }
    assert_ids %w(d e f), for: search
  end

  test "greater than" do
    search = Album.ion.search { number :play_count, gt: 3 }
    assert_ids %w(d e f g h), for: search
  end

  test "greater than or equal" do
    search = Album.ion.search { number :play_count, min: 3 }
    assert_ids %w(c d e f g h), for: search
  end

  test "less than or equal" do
    search = Album.ion.search { number :play_count, max: 3 }
    assert_ids %w(a b c), for: search
  end

  test "greater than and less than" do
    search = Album.ion.search { number :play_count, lt: 5, gt: 1 }
    assert_ids %w(b c d e f), for: search
  end

  test "greater than equal and less than equal" do
    search = Album.ion.search { number :play_count, min: 1, max: 3 }
    assert_ids %w(a b c), for: search
  end
end
