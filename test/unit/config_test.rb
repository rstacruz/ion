require_relative '../test_helper'

class ConfigTest < Test::Unit::TestCase
  setup do
    # Mock erasing the config
    Ion.instance_variable_set :@config, nil
    @config = Ion.config
  end

  test "config" do
    assert @config.is_a?(Ion::Config)
  end

  test "ignored words" do
    assert @config.ignored_words.include?('a')
  end

  test "question mark" do
    assert @config.ignored_words?

    assert ! @config.foobar?
    @config.foobar = 2
    assert @config.foobar?
  end
end
