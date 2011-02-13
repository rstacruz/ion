require_relative '../test_helper'

class BoostTest < Test::Unit::TestCase
  setup do
    # Fake entries that should NOT be returned
    5.times { Album.create title: lorem, body: '' }

    @items = {
      :a => Album.create(title: "Morning Scifi"),
      :b => Album.create(title: "Intensify", body: 'Special Edition'),
      :c => Album.create(title: "BT Emotional Technology", body: 'Special Edition'),
      :d => Album.create(title: "BT Movement in Still Life")
    }
  end

  test "scores" do
    search = Album.ion.search {
      text :title, "bt"
      boost(2.5) { text :body, "special edition" }
    }

    assert_ids %w(c d), for: search, ordered: true

    @scores = scores_for search
    assert_score c: 2.5
    assert_score d: 1.0
  end

  test "scores 2" do
    search = Album.ion.search {
      text :title, "bt"
      boost(0.5) { text :body, "special edition" }
    }

    assert_ids %w(d c), for: search, ordered: true

    @scores = scores_for search
    assert_score c: 0.5
    assert_score d: 1.0
  end
end
