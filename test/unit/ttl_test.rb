require_relative '../test_helper'

class TtlTest < Test::Unit::TestCase
  test "key TTL test" do
    Album.create title: "Vloop", body: "Secher Betrib"

    old_keys = redis.keys('Ion:*').reject { |s| s['~'] }

    # This should make a bunch of temp keys
    search = Album.ion.search {
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

    search.ids

    # Ensure all temp keys will die eventually
    keys = redis.keys('Ion:~:*')
    keys.each { |key|
      ttl = redis.ttl(key)
      assert ttl >= 0
    }

    new_keys = redis.keys('Ion:*').reject { |s| s['~'] }

    # Ensure that no keys died
    assert_equal old_keys.sort, new_keys.sort

    # Ensure they're all alive
    new_keys.each { |key| assert_equal -1, redis.ttl(key) }
  end
end
