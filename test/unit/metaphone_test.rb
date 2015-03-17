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

  def after_save
    update_ion_indices
  end

  def after_delete
    delete_ion_indices
  end
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
