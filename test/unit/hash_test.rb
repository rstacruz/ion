require_relative '../test_helper'

class HashTest < Test::Unit::TestCase
  setup do
    @search1 = Album.ion.search {
      text :title, "Vloop"
      text :body, "Secher betrib"
      any_of {
        text :body, "betrib"
        text :body, "betrib"
        any_of {
          text :body, "betrib"
          text :body, "betrib"
        }
      }
    }

    @search2 = Album.ion.search {
      text :title, "Vloop"
      text :body, "Secher betrib"
      any_of {
        text :body, "betrib"
        text :body, "betrib"
        any_of {
          text :body, "betrib"
          text :body, "betrib"
        }
      }
    }

    @search3 = Album.ion.search {
      text :title, "Vloop"
      text :body, "Secher betrib"
      any_of {
        text :body, "betrib"
        text :body, "betrib"
        score(2.5) {
          text :body, "betrib"
        }
      }
      boost(2.0) { text :title, "x" }
    }
  end

  test "hash test" do
    assert_equal @search1.to_hash, @search2.to_hash
    assert @search3.to_hash != @search2.to_hash
    # puts @search3.inspect
  end
end
