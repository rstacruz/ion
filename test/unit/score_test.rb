require_relative '../test_helper'

class Score < Test::Unit::TestCase
  setup do
    # Fake entries that should NOT be returned
    10.times { Album.create title: lorem, body: '' }

    @items = {
      :a => Album.create(title: "Secher glite"),
      :b => Album.create(title: "Shebboleth mordor"),
      :c => Album.create(title: "Rexan ruffush"),
      :d => Album.create(title: "Parctris leroux")
    }
  end

  test "nested 1" do
    search = Album.ion.search {
      score(2.0) {
        text :title, "secher"
      }
    }

    assert_ids %w(a), for: search
    return #pending

    # id, score = search.key.zrange(0, -1, with_scores: true)
    # assert_equal 2, score
  end
end
