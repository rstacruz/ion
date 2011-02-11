require 'test_helper'

class IT::Song < Ohm::Model
  include Ion::Entity
  include Ohm::Callbacks

  attribute :title
  attribute :body

  ion {
    text :title
    metaphone :body
  }

  after :save, :update_ion_indices
end

Song = IT::Song

class MetaphoneTest < Test::Unit::TestCase
  setup do
    # Fake entries that should NOT be returned
    10.times { Song.create title: Faker::Company.bs, body: '' }
  end

  test "metaphone" do
    items = [
      Song.create(body: "Stephanie"),
      Song.create(body: "Ztephanno")
    ]
    search = Song.ion.search { metaphone :body, "Stefan" }

    assert_equal items.map(&:id).sort, search.ids.sort
  end

end
