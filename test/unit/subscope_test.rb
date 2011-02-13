require_relative '../test_helper'

class SubscopeTest < Test::Unit::TestCase
  setup do
    # Fake entries that should NOT be returned
    10.times { Album.create title: phrase, body: '' }

    @items = {
      :a => Album.create(title: "Secher glite"),
      :b => Album.create(title: "Shebboleth mordor"),
      :c => Album.create(title: "Rexan ruffush"),
      :d => Album.create(title: "Parctris leroux")
    }
  end

  test "nested 1" do
    search = Album.ion.search {
      any_of {
        text :title, "secher"
        text :title, "mordor"
        all_of {
          text :title, "rexan"
          text :title, "ruffush"
        }
      }
    }

    assert_ids %w(a b c), for: search
  end

  test "nested 2" do
    search = Album.ion.search {
      any_of {
        text :title, "shebboleth"
        all_of {
          text :title, "rexan"
          text :title, "ruffush"
        }
      }
    }

    assert_ids %w(b c), for: search
  end
end
