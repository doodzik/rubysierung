require 'rubysierung/ast'

module Rubysierung
  module Core
    def get_default_hash_from_fileline(file:, line:)
      ruby_str = IO.readlines(file)[line]
      ast = Rubysierung::ASTStaticDefault.new(ruby_str)
      param_hash, defaults = ast.method.params
      @__defaults = @__defaults.merge(defaults)
      convert_value_to_constant param_hash
    end

    def call(klass_hash:, value_hash:)
      return value_hash if klass_hash.empty?
      return_hash = each_param(klass_hash, value_hash) do
        |key| @__error_data[:var_sym] = key
      end
      value_hash.merge return_hash
    end

    private

    def each_param(klass_hash, value_hash)
      return_hash = {}
      klass_hash.keys.map do |key|
        yield(key) if block_given?
        # TODO: don't use eval -> String.new('default') something like this
        value = value_hash[key] ? value_hash[key] : eval(@__defaults[key])
        return_hash[key] = convert(klass: klass_hash[key], value: value)
      end
      return_hash
    end

    def convert(klass:, value: nil)
      strict, klass = get_kind(klass: klass)
      type = @__types.reject { |t| klass != t[0] }.flatten
      klass == type[0] ? value.send(type[1 + strict]) : value
    rescue NoMethodError
      @__error_data.merge(klass: klass, type: type[1 + strict],
                          value: value, value_class: value.class)
      raise Rubysierung::Error.new(@__error_data).raise_child strict
    end

    def get_kind(klass:)
      if klass.respond_to? :name
        splitted, splitted1 = klass.name.split('::')
        splitted == 'Strict' ? [1, Kernel.const_get(splitted1)] : [0, klass]
      else
        [0, klass]
      end
    end

    def convert_value_to_constant(hash)
      Hash[hash.map do |k, v|
        [k.to_sym, Kernel.const_get(v)]
      end]
    end
  end
end
