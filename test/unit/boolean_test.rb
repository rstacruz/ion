require_relative '../test_helper'

class BooleanTest < Test::Unit::TestCase
  setup do
  end

  test "boolean search" do
    @items = {
      :a => Album.create(available: true,  title: "Morning Scifi"),
      :b => Album.create(available: true,  title: "Intensify", body: 'Special Edition'),
      :c => Album.create(available: false, title: "BT Emotional Technology", body: 'Special Edition'),
      :d => Album.create(available: false, title: "BT Movement in Still Life")
    }
    search = Album.ion.search { boolean :available, true }
    assert_ids %w(a b), for: search
  end

  test "forgiving boolean indexing" do
    @items = {
      :a => Album.create(available: true,  title: "Morning Scifi"),
      :b => Album.create(available: 'true',  title: "Intensify", body: 'Special Edition'),
      :c => Album.create(available: false, title: "BT Emotional Technology", body: 'Special Edition'),
      :d => Album.create(available: 'false', title: "BT Movement in Still Life"),
      :g => Album.create(available: 0,  title: "Morning Scifi"),
      :h => Album.create(available: '0',  title: "Intensify", body: 'Special Edition'),
      :i => Album.create(available: true, title: "BT Emotional Technology", body: 'Special Edition'),
      :j => Album.create(available: 'monkey', title: "BT Movement in Still Life")
    }

    search = Album.ion.search { boolean :available, true }
    assert_ids %w(a b i j), for: search
  end
end
