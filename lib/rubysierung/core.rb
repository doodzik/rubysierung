require 'rubysierung/ast'

module Rubysierung
  module Core

    def get_default_hash_from_fileline(file:, line:)
      param_hash, defaults = Rubysierung::ASTDefaultStatic.new(IO.readlines(file)[line]).method.params
      @__defaults = @__defaults.merge(defaults)
      convert_value_to_constant param_hash
    end

    def call(klass_hash:, value_hash:)
      return_hash = {}
      return value_hash if klass_hash.empty?
      klass_hash.keys.map do |key|
        @__error_data[:var_sym] = key
        value = value_hash[key] ? value_hash[key] : eval(@__defaults[key])
        return_hash[key] = convert(klass: klass_hash[key], value: value)
      end
      value_hash.merge return_hash
    end

    private

    def convert(klass:, value: nil)
      strict = 0
      @__types.map do |type|
        strict, klass = get_kind(klass: klass)
        klass == type[0] and return value.send(type[1 + strict])
      end
      value
    rescue NoMethodError
      @__error_data.merge({ klass: klass, type: type[1 + strict], value: value, value_class: value.class })
      # TODO: shorten
      fail strict == 0 ? Rubysierung::Error::Standard.new(@__error_data) : Rubysierung::Error::Strict.new(@__error_data)
    end

    def get_kind(klass:)
      if klass.respond_to? :name
        splitted = klass.name.split('::')
        splitted[0] == 'Strict' ? [1, Kernel.const_get(splitted[1])] : [0, klass]
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
