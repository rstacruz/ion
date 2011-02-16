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
  end

  test "load from hash" do
    hash = {"scopes"=>[{"gate"=>"any", "scopes"=>[{"gate"=>"any", "score"=>2.5, "searches"=>[{"index"=>{"type"=>"text", "name"=>"body"}, "value"=>"betrib"}]}], "searches"=>[{"index"=>{"type"=>"text", "name"=>"body"}, "value"=>"betrib"}, {"index"=>{"type"=>"text", "name"=>"body"}, "value"=>"betrib"}]}], "searches"=>[{"index"=>{"type"=>"text", "name"=>"title"}, "value"=>"Vloop"}, {"index"=>{"type"=>"text", "name"=>"body"}, "value"=>"Secher betrib"}], "boosts"=>[{"scope"=>{"searches"=>[{"index"=>{"type"=>"text", "name"=>"title"}, "value"=>"x"}]}, "amount"=>2.0}]}
    h = Album.ion.search hash
    assert @search3.to_hash == h.to_hash
  end

  test "load from hash 2" do
    hash = @search1.to_hash
    h = Album.ion.search hash
    assert @search2.to_hash == h.to_hash
  end
end
