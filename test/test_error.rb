require 'minitest/autorun'
require 'Rubysierung/Error'

class SetupError
  attr_reader :__error_data
  def initialize
    @__error_data = {}
  end

  def example
    Rubysierung::Error.set_data(_self:self, name:42, method_object:42, file:42, line:42)
  end
end

class RubysierungErrorTest < Minitest::Test
  def test_Error
    data = {}
    [:klass,:type,:method_object,:method_file,:method_name,:method_line,:caller,:var_sym,:value,:value_class,:type].map { |sym| data[sym] = '42' }
    raise Rubysierung::Error.new(data)
  rescue Rubysierung::Error => e
    assert_equal("Class:42, DuckType:42, Method:42:42 42:42 -- called on 42 with 42:42 of 42 doesn't respond to 42", e.message)
  end

  def test_Error_Standard
    data = {}
    [:klass,:type,:method_object,:method_file,:method_name,:method_line,:caller,:var_sym,:value,:value_class,:type].map { |sym| data[sym] = '42' }
    raise Rubysierung::Error::Standard.new(data)
  rescue Rubysierung::Error::Standard => e
    assert_equal("Rubysierung::Error::Standard: Class:42, DuckType:42, Method:42:42 42:42 -- called on 42 with 42:42 of 42 doesn't respond to 42", e.message)
  end

  def test_Error_Strict
    data = {}
    [:klass,:type,:method_object,:method_file,:method_name,:method_line,:caller,:var_sym,:value,:value_class,:type].map { |sym| data[sym] = '42' }
    raise Rubysierung::Error::Strict.new(data)
  rescue Rubysierung::Error::Strict => e
    assert_equal("Rubysierung::Error::Strict: Class:42, DuckType:42, Method:42:42 42:42 -- called on 42 with 42:42 of 42 doesn't respond to 42", e.message)
  end

  def test_set_data
    s_e = SetupError.new
    s_e.example
    assert_equal({method_object: 42, method_file: 42, method_name: 42, method_line: 42} ,s_e.__error_data)
  end

end
