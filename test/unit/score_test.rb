require_relative '../test_helper'

class ScoreTest < Test::Unit::TestCase
  setup do
    # Fake entries that should NOT be returned
    5.times { Album.create title: lorem, body: '' }

    @items = {
      :a => Album.create(title: "Secher glite"),
      :b => Album.create(title: "Shebboleth mordor"),
      :c => Album.create(title: "Rexan ruffush"),
      :d => Album.create(title: "Parctris leroux")
    }
  end

  test "scores" do
    search = Album.ion.search {
      score(2.5) {
        text :title, "secher"
      }
    }

    assert_ids %w(a), for: search

    scores = scores_for search
    assert_equal 2.5, scores[@items[:a].id].to_f
  end

  test "nested scores" do
    search = Album.ion.search {
      score(2.5) {
        score(2.0) {
          text :title, "secher"
        }
      }
    }

    assert_ids %w(a), for: search

    scores = scores_for search
    assert_equal 5.0, scores[@items[:a].id].to_f
  end
end
