require 'minitest/autorun'
require 'ast/ast'

class AstTest < Minitest::Test
  def test_params
    ast = AST.new "def self.example2(foo: Strict::String, bar: Integer, buz: String||'fu')"
    result = ast.send :params
    assert_equal({"foo"=>"Strict::String", "bar"=>"Integer", "buz"=>"String||'fu'"}, result)
  end

  def test_method
    ast = AST.new ''
    assert_equal ast, ast.method
  end

  def test_regex_isnt_constant
    ast = AST.new ''
    regex = ast.send :regex_isnt_constant#/^[^A-Z]/
    assert_equal(nil, regex  =~ 'Foo')
    assert_equal(0, regex  =~ 'foo')
  end

  def test_regex_keyword_param
    ast = AST.new ''
    regex = ast.send :regex_keyword_param#/([a-z][a-zA-Z]+):\s*([^,\n)]+)/
    str = "def self.example2(foo: Strict::String, bar: Integer, buz: String||'fu')"
    assert_equal(str.scan(regex).flatten,
          ['foo', 'Strict::String', 'bar', 'Integer', 'buz', "String||'fu'"])
  end

  def test_get_param_hash
    # @param declaration_string [String] the string which is being evaluated
    # @return [Hash<String, String>] parameter of a method
    ast = AST.new ''
    str = "def self.example2(foo: Strict::String, bar: Integer, buz: String||'fu')"
    result = ast.send :get_param_hash, str
    assert_equal({"foo"=>"Strict::String", "bar"=>"Integer", "buz"=>"String||'fu'"}, result)
  end
end
