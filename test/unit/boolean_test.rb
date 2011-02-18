require_relative '../test_helper'

class BooleanTest < Test::Unit::TestCase
  setup do
    # Fake entries that should NOT be returned
    @items = {
      :a => Album.create(available: true,  title: "Morning Scifi"),
      :b => Album.create(available: true,  title: "Intensify", body: 'Special Edition'),
      :c => Album.create(available: false, title: "BT Emotional Technology", body: 'Special Edition'),
      :d => Album.create(available: false, title: "BT Movement in Still Life")
    }
  end

  test "boolean search" do
    search = Album.ion.search { boolean :available, true }
    assert_ids %w(a b), for: search
  end
end
