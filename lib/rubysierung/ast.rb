
module Rubysierung
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

  class ASTStaticDefault < AST
    # Calls super and uses it result as a arg for default_param
    # @return [Array<Hash<>, Hash<Symbol, String>>] returns the same as default_param
    def params
      default_param super
    end

    private

    # @return [Regex] splits default param and type
    def regex_default_arg
      /([A-Z]\w*?)\s*\|\|\s*(.+)/
    end

    # seperates a param from default argument and stores the defaults inside a hash
    # @param hash [Hash<String, String>] {"foo"=>"String||'bar'", "bar"=>"String||'foo'"}
    # @return [Array<Hash<String, String>, Hash<Symbol, String>>] params, defaults for params
    def default_param(hash)
      defaults = {}
      hash.map do |k, v|
        const, default = v.scan(regex_default_arg).flatten
        next unless const && default
        hash[k], defaults[k.to_sym] = [const, default]
      end
      [hash, defaults]
    end
  end
end
