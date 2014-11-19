require 'minitest/autorun'
require 'CallBaecker'
require 'rubysierung'

class Strict::CustomTyp;end
class CustomTyp;end


class SetupRubysierungTypes
  extend Rubysierung
  include CallBaecker

  @__add_type[CustomTyp, :to_s, :to_str]

  # custom Class
  def self.example1(foo: ,bar: CustomTyp)
    [foo, bar]
  end

  # strict
  def self.example2(foo: Strict::String, bar: Integer)
    [foo, bar]
  end

  # Custom strict
  def self.example3(foo: Strict::String, bar: Strict::CustomTyp)
    [foo, bar]
  end
end

class RubysierungTypesTest < Minitest::Test
  def test_example_1_custum_type
    foo, bar = SetupRubysierungTypes.example1(foo: 4, bar: 3)
    assert_equal('3', bar)
    assert_equal(4, foo)
  end

  def test_example_2_strict_type
    foo, bar = SetupRubysierungTypes.example2(foo: '4', bar: 2)
    assert_equal(2, bar)
    assert_equal('4', foo)
    begin
     SetupRubysierungTypes.example2(foo: 4, bar: 2)
      assert_equal(false, true)
    rescue StandardError => e
      assert_equal(true, true)
    end
  end

  def test_example_3_custum_type_strict
    foo, bar = SetupRubysierungTypes.example3(foo: '4', bar: 'hi')
    assert_equal('hi', bar)
    assert_equal('4', foo)
  end
end
