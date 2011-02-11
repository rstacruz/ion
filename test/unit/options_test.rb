require_relative '../test_helper'

class IT::Options < Ohm::Model
  include Ion::Entity
  include Ohm::Callbacks

  attribute :text
end

class OptionsTest < Test::Unit::TestCase
  test "foo" do
    assert_raise(Ion::InvalidIndexType) do
      IT::Options.ion {
        field :footype, :text
      }
    end
  end
end
