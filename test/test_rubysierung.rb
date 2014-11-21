require 'minitest/autorun'
require 'rubysierung'

class SetupRubysierung
  extend Rubysierung

  def example1(foo: String, bar: Integer)
    [foo, bar]
  end

  def self.example2(foo: String, bar: Integer)
    [foo, bar]
  end

  def self.example3(foo:, bar: 'hallo World')
    [foo, bar]
  end

  # Default
  def self.example4(foo: String||'bar', bar: String||'foo')
    [foo, bar]
  end

  # Default
  def self.example_err(foo: Strict::String, bar: String||'foo')
    [foo, bar, __LINE__]
  end
end

class RubysierungTest < Minitest::Test
  def test_error_implementation
    SetupRubysierung.example_err(foo: 4, bar: '3')
  rescue Rubysierung::Error::Strict => e
    foo, bar, line = SetupRubysierung.example_err(foo: '4', bar: '3')
    line_now = __LINE__ - 1
    line    -= 1
    file     = __FILE__
    method_name = 'example_err'
    in_method = 'test_error_implementation'
    method_on_class = 'SetupRubysierungTypes'
    err_class = 'Rubysierung::Error::Strict'
    str = "#{err_class} Class: Strict::String, Conversion Method: to_str, Method:#{method_on_class}:#{file} #{method_name}:#{line} -- called on #{file}:#{line_now}:in `rescue in #{in_method}' with foo: 4 of Integer doesn't respond to to_str"
    assert_equal(str, e.message)
  end

  def test_example_2_standart
    foo, bar = SetupRubysierung.example2(foo: 4, bar: '3')
    assert_equal(3, bar)
    assert_equal('4', foo)
  end

  def test_example_1_instance_method
    foo, bar = SetupRubysierung.new.example1(foo: 4, bar: '3')
    assert_equal(3, bar)
    assert_equal('4', foo)
  end

  def test_example_3_default_works
    foo, bar = SetupRubysierung.example3(foo: 4)
    assert_equal('hallo World', bar)
    assert_equal(4, foo)
  end

  def test_example_4_default_value
    foo, bar = SetupRubysierung.example4(bar: 'buz')
    assert_equal('buz', bar)
    assert_equal('bar', foo)
  end
end
