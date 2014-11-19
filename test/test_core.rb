require 'minitest/autorun'
require 'rubysierung'


class RubysierungCoreTest < Minitest::Test
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
end
