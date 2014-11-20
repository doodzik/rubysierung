require 'minitest/autorun'
require 'rubysierung/ast'

class RubysierungAstTest < Minitest::Test
  def test_params
    ast = Rubysierung::AST.new "def self.example2(foo: Strict::String, bar: Integer, buz: String||'fu')"
    param, default = ast.params
    assert_equal({"foo"=>"Strict::String", "bar"=>"Integer", "buz"=>"String"}, param)
    assert_equal({:buz=>"'fu'"}, default)
  end

  def test_regex_default_arg
    ast = Rubysierung::AST.new ''
    regex = ast.send :regex_default_arg
    str = "String||'fu'"
    assert_equal(str.scan(regex).flatten, ['String', "'fu'"])
  end

  def test_default_param
    ast = Rubysierung::AST.new ''
    param, default = ast.send :default_param, {"foo"=>"String||'bar'", "bar"=>"String||'foo'"}
    assert_equal({'foo' => 'String', 'bar' => 'String'}, param)
    assert_equal({foo: "'bar'", bar: "'foo'"}, default)
  end
end
