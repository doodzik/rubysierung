require 'rubysierung/error'

module Rubysierung
  module Core
    # sets defaults as @__defaults
    # @param ast [AST] an instance of modefied ruby ast class
    # @todo refactor into adapter
    # @return [Hash<Symbol, Constant>]
    def default_hash(ast)
      param_hash, defaults = ast.method.params
      @__defaults = @__defaults.merge(defaults)
      convert_value_to_constant param_hash
    end

    # applies conversion methods on args and returns args(for CallBaecker)
    # @param klass_hash [Hash<Symbol, Constant>] holds types for Arguments
    # @param value_hash [Hash<Symbol, Constant>] holds values for Arguments
    # @return [Hash<Symbol, Constant>] same as value_hash only that on its
    #   values the type was applied and merged with the other values
    def call(klass_hash:, value_hash:)
      return value_hash if klass_hash.empty?
      return_hash = each_param(klass_hash, value_hash) do
        |key| @__error_data[:var_sym] = key
      end
      value_hash.merge return_hash
    end

    private

    # @param klass_hash [Hash<Symbol, Constant>] holds types for Arguments
    # @param value_hash [Hash<Symbol, Constant>] holds values for Arguments
    # @yield [Symbol] param name
    # @todo don't use eval -> String.new('default') something like this
    # @todo refactor: i can't point my finger on it, but it feels bad
    # @return [Hash] same as value_hash only that on its
    #   values the type was applied
    def each_param(klass_hash, value_hash)
      return_hash = {}
      klass_hash.keys.map do |key|
        yield(key) if block_given?
        value = value_hash[key] ? value_hash[key] : eval(@__defaults[key])
        return_hash[key] = convert(klass: klass_hash[key], value: value)
      end
      return_hash
    end

    # @param klass [Hash<>]
    # @option value [Hash<>]
    # @raise [Rubysierung::Error:Standard|Rubysierung::Error::Strict]
    # @return [self]
    def convert(klass:, value: nil)
      strict, klass = get_kind(klass: klass)
      type = @__types.reject { |t| klass != t[0] }.flatten
      klass == type[0] ? value.send(type[1 + strict]) : value
    rescue NoMethodError
      @__error_data.merge(klass: klass, type: type[1 + strict],
                          value: value, value_class: value.class)
      raise Rubysierung::Error.new(@__error_data).raise_child strict
    end

    # @param klass [String] takes the type of a klass
    # @return [Array<Int, Constant>] if klass is Strict it returns 1 else 0 as
    #     the int. So that we can look up the conversion method in @__types
    #     and a klass without strict prefix
    def get_kind(klass:)
      if klass.respond_to? :name
        splitted, splitted1 = klass.name.split('::')
        splitted == 'Strict' ? [1, Kernel.const_get(splitted1)] : [0, klass]
      else
        [0, klass]
      end
    end

    # @note this could be the point where we could use Symbols instead
    #    of Constants.
    # @param hash [Hash<String, String>] takes a string string hash
    # @todo refactor into adapter
    # @return [Hash<Symbol, Constant>] returns a symbol Constant hash
    def convert_value_to_constant(hash)
      Hash[hash.map do |k, v|
        [k.to_sym, Kernel.const_get(v)]
      end]
    end
  end
end
