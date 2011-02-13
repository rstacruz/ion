require_relative '../test_helper'

class UpdateTest < Test::Unit::TestCase
  setup do
    # Fake entries that should NOT be returned
    5.times { Album.create title: lorem, body: '' }
  end

  test "Deleting records" do
    item   = Album.create title: "Shobeh"
    search = Album.ion.search { text :title, "Shobeh" }
    id     = item.id

    # Search should see it
    assert_equal [id], search.ids

    item.delete
    assert Album[id].nil?

    search = Album.ion.search { text :title, "Shobeh" }
    assert_equal [], search.ids
  end

  test "Editing records" do
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
