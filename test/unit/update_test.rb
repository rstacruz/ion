require_relative '../test_helper'

class UpdateTest < Test::Unit::TestCase
  setup do
    # Fake entries that should NOT be returned
    # 10.times { Album.create title: Faker::Company.bs, body: '' }
  end

  test "delete" do
    #return #pending

    # I've no idea why this actually works.
    item   = Album.create title: "Shobeh"
    search = Album.ion.search { text :title, "Shobeh" }
    id     = item.id

    # Search should see it
    assert_equal [id], search.ids

    item.delete
    assert Album[id].nil?

    search = Album.ion.search { text :title, "Shobeh" }

    keys = redis.keys("Ion:*")
    keys.each do |k|
      next if k.include?('~')
      p k
      p redis.zrange(k,0,-1)
    end
    assert_equal [], search.ids
  end

  test "editing" do
    item   = Album.create title: "Heshela"
    search = Album.ion.search { text :title, "Heshela" }
 
    # Search should see it
    assert_equal [item.id], search.ids
 
    # Edit
    item.title = "Mathroux"
    item.save
 
    # Now search should not see it
    search = Album.ion.search { text :title, "Heshela" }
    assert_equal [], search.ids
 
    search = Album.ion.search { text :title, "mathroux" }
    assert_equal [item.id], search.ids
  end
end
