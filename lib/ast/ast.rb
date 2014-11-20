class AST < Struct.new(:to_parse)
  # @return [Hash<String, String>] parameter of a method
  def params
    get_param_hash to_parse
  end

  # just so it makes sense in contest of the ast
  # @return [self] make it chainable
  def method
    self
  end

  private

  # @param declaration_string [String] the string which is being evaluated
  # @return [Hash<String, String>] parameter of a method
  def get_param_hash(declaration_string)
    Hash[
      *declaration_string.scan(regex_keyword_param).flatten
    ].reject { |_, v| v =~ regex_isnt_constant }
  end

  # @return [Regex] which returns keywords and value from ruby string
  def regex_keyword_param
    /([a-z][a-zA-Z]+):\s*([^,\n)]+)/
  end

  # @return [Regex] which checks if the String isn't a Constant
  def regex_isnt_constant
    /^[^A-Z]/
  end
end
