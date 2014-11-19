module Rubysierung
  class AST < Struct.new(:to_parse)
    def params
      get_param_hash to_parse
    end

    def method
      self
    end

    private

    def get_param_hash(declaration_string)
      Hash[
        *declaration_string.scan(regex_keyword_param).flatten
      ].reject { |_, v| v =~ regex_is_constant }
    end

    def regex_keyword_param
      /([a-z][a-zA-Z]+):\s*([^,\n)]+)/
    end

    def regex_is_constant
      /^[^A-Z]/
    end
  end

  class ASTStaticDefault < AST
    def params
      default_param super
    end

    private

    def regex_default_arg
      /([A-Z]\w*?)\s*\|\|\s*(.+)/
    end

    def default_param(hash)
      defaults = {}
      hash1 = {}
      hash.map do |k, v|
        const, default = v.scan(regex_default_arg).flatten
        next unless const && default
        hash1[k] = const
        defaults[k.to_sym] ||= {}
        defaults[k.to_sym] = default
      end
      [hash.merge(hash1), defaults]
    end
  end
end
