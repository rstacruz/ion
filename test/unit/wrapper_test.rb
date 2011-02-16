require_relative '../test_helper'

class WrapperTest < Test::Unit::TestCase
  setup do
    # Falses
    5.times { Album.create title: lorem, body: '' }
  end

  test "wrapper" do
    10.times { Album.create :title => "Foo #{lorem}" }

    person = Ion::Wrapper.new('IT::Album')

    person.ion { text :title }

    search = person.ion.search { text :title, "Foo" }

    search2 = Album.ion.search { text :title, "Foo" }

    assert search.to_hash == search2.to_hash
    assert search.ids == search2.ids
    assert search.ids.any?
  end
end
