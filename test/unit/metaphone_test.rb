require_relative '../test_helper'

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
    5.times { Song.create title: lorem, body: '' }

    @items = {
      a: Song.create(body: "Stephanie"),
      b: Song.create(body: "Ztephanno..!")
    }
  end

  test "metaphone" do
    search = Song.ion.search { metaphone :body, "Stefan" }

    assert_ids %w(a b), for: search
  end

end
