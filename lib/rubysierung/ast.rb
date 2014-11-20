require 'ast/ast'

module Rubysierung
  class AST < AST
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
