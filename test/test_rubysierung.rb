require 'minitest/autorun'
require 'CallBaecker'
require 'rubysierung'

class CustomTyp
end

class Setup
  extend Rubysierung
  include CallBaecker

  @__add_type[CustomTyp, :to_s, :to_str]

  def example1(foo: String, bar: Integer)
    [foo, bar]
  end

  def self.example2(foo: String, bar: Integer)
    [foo, bar]
  end

  def self.example3(foo: , bar: 'hallo World')
    [foo, bar]
  end

  # custom Class
  def self.example4(foo: ,bar: CustomTyp)
    [foo, bar]
  end

  # strict
  def self.example5(foo: Strict::String, bar: Integer)
    [foo, bar]
  end

  # Default
  def self.example6(foo: String||'bar', bar: String||'foo')
    [foo, bar]
  end
end

class RubysierungTest < Minitest::Test
  def test_rubisierung_converte_Int_to_string
    assert_equal('23', Rubysierung.convert(klass: String, value: 23))
  end
  def test_rubisierung_converte_string_to_Int
    assert_equal(23, Rubysierung.convert(klass: Integer, value: '23'))
  end

  def test_rubisierung_converte_pass_nonexisting_klass_then_return_value
    assert_equal('23', Rubysierung.convert(klass: 'huhu', value: '23'))
  end

  def test_run_type_hash_agains_value_hash
    assert_equal({foo: 23, bar:'23'},
                 Rubysierung.convert_multiple(value_hash: {foo: '23', bar: 23},
                                              klass_hash: {foo: Integer, bar: String}))
  end
  def test_run_type_hash_agains_value_hash_without_a_class_on_klass_hash
    assert_equal({foo: '23', bar:'23'},
                 Rubysierung.convert_multiple(value_hash: {foo: '23', bar: 23},
                                              klass_hash: {foo: 14, bar: String}))
  end

  def test_is_strict
    assert_equal([0, String], Rubysierung.get_kind(klass: String))
    assert_equal([1, String], Rubysierung.get_kind(klass: Strict::String))
  end

  def test_example_2_standart
    foo, bar= Setup.example2(foo: 4, bar: '3')
    assert_equal(3, bar)
    assert_equal('4', foo)
  end

  def test_example_1_instance_method
    foo, bar= Setup.new.example1(foo: 4, bar: '3')
    assert_equal(3, bar)
    assert_equal('4', foo)
  end

  def test_example_3_default_works
    foo, bar= Setup.example3(foo: 4)
    assert_equal('hallo World', bar)
    assert_equal(4, foo)
  end

  def test_example_4_custum_type
    foo, bar = Setup.example4(foo: 4, bar: 3)
    assert_equal('3', bar)
    assert_equal(4, foo)
  end

  def test_example_5_strict_type
    foo, bar = Setup.example5(foo: '4', bar: 2)
    assert_equal(2, bar)
    assert_equal('4', foo)
    begin
      Setup.example5(foo: 4, bar: 2)
      assert_equal(false, true)
    rescue StandardError => e
      assert_equal(true, true)
    end
  end

  def test_example_6_default_value
     foo, bar = Setup.example6(bar: 'buz')
     assert_equal('buz', bar)
     assert_equal('bar', foo)
   end
end
