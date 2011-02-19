require_relative '../test_helper'

class Stopwords < Test::Unit::TestCase
  setup do
    # Fake entries that should NOT be returned
    5.times { Album.create title: lorem, body: '' }

    @items = {
      :a => Album.create(title: "Morning Scifi"),
      :b => Album.create(title: "Intensify", body: 'Special Edition'),
      :c => Album.create(title: "Can't Emotional Technology", body: 'Special Edition'),
      :d => Album.create(title: "UNKLE Where Didn't The Night Fall")
    }
  end

  test "stopwords" do
    search = Album.ion.search { text :title, "morning is the scifi" }
    assert_ids %w(a), for: search
  end

  test "" do
    search = Album.ion.search { text :title, "u.n.k.l.e." }
    assert_ids %w(d), for: search
  end
end
