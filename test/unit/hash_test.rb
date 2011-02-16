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
        any_of {
          text :body, "betrib"
        }
      }
    }
  end

  test "hash test" do
    assert_equal @search1.to_hash, @search2.to_hash
    assert @search3.to_hash != @search2.to_hash
  end
end
