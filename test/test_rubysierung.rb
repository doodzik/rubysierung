require 'minitest/autorun'
require 'CallBaecker'
require 'rubysierung'

class SetupRubysierung
  extend Rubysierung
  include CallBaecker

  def example1(foo: String, bar: Integer)
    [foo, bar]
  end

  def self.example2(foo: String, bar: Integer)
    [foo, bar]
  end

  def self.example3(foo: , bar: 'hallo World')
    [foo, bar]
  end

  # Default
  def self.example4(foo: String||'bar', bar: String||'foo')
    [foo, bar]
  end
end

class RubysierungTest < Minitest::Test
  def test_example_2_standart
    foo, bar= SetupRubysierung.example2(foo: 4, bar: '3')
    assert_equal(3, bar)
    assert_equal('4', foo)
  end

  def test_example_1_instance_method
    foo, bar= SetupRubysierung.new.example1(foo: 4, bar: '3')
    assert_equal(3, bar)
    assert_equal('4', foo)
  end

  def test_example_3_default_works
    foo, bar= SetupRubysierung.example3(foo: 4)
    assert_equal('hallo World', bar)
    assert_equal(4, foo)
  end

  def test_example_4_default_value
     foo, bar = SetupRubysierung.example4(bar: 'buz')
     assert_equal('buz', bar)
     assert_equal('bar', foo)
  end
end
