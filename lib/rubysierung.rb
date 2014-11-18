require "rubysierung/version"
require 'rubysierung/types'
require 'rubysierung/error'

module Rubysierung
  def self.extended(base)
    base.instance_variable_set :@__types_show, -> () do
      puts @__types
    end

    base.instance_variable_set :@__add_type, -> (klass, standard, strict) do
      @__types << [klass, standard, strict]
    end

    base.instance_variable_set :@__before_hook, -> (i,ii, callee) do
      @__error_data[:caller] = callee
      Rubysierung.convert_multiple(klass_hash: i, value_hash: ii)
    end

    base.instance_variable_set :@__setup_instance_method, -> (_self, name) do
      file, line = _self.instance_method(name.to_sym).source_location
      set_error_data(_self: self, name: name, method_object: _self.name, file: file, line: line - 1)
      get_default_hash_from_fileline(file: file, line: line-1)
    end

    base.instance_variable_set :@__setup_class_method, -> (_self, name) do
      file, line = _self.method(name.to_sym).source_location
      set_error_data(_self: self, name: name, method_object: _self.name, file: file, line: line - 1)
      get_default_hash_from_fileline(file: file, line: line-1)
    end
  end

  @__types = Rubysierung::Types.types
  @__error_data = {}
  class << self
    def get_default_hash_from_fileline(file:, line:)
      params_matcher =  /([a-z][a-zA-Z]+):\s*([^,\n)]+)/
      def_line = IO.readlines(file)[line]
      flatten_hash = Hash[*def_line.scan(params_matcher).flatten]
      myhash = flatten_hash.reject { |k,v| v =~ /^[^A-Z]/}
      Hash[myhash.map{|(k,v)| [k.to_sym, Kernel.const_get(v)]}]
    end

    def convert_multiple(klass_hash:, value_hash:)
      return_hash = {}
      return value_hash if klass_hash.empty?
      klass_hash.keys.map do |key|
        @__error_data[:var_sym] = key
        return_hash[key] = convert(klass: klass_hash[key], value: value_hash[key])
      end
      value_hash.merge return_hash
    end

    def convert(klass:, value:)
      strict = 0
      @__types.map do |type|
        strict, klass = get_kind(klass: klass)
        begin
          if klass == type[0]
            return value.send(type[1+strict])
          end
        rescue NoMethodError
          # return argument, param, duck_type, calle/receiver -> file, line
          if strict == 0
            raise Rubysierung::Error::Standard, "Rubysierung::Error::Standard: Class:#{klass}, DuckType:#{type[2]}, Method:#{@__error_data[:method_object]}:#{@__error_data[:method_file]}#{@__error_data[:method_name]}:#{@__error_data[:method_line]} -- called on #{@__error_data[:caller]} with #{@__error_data[:var_sym]}:#{value} of #{value.class} doesn't respond to #{type[2]}"
          else
            raise Rubysierung::Error::Strict, "Rubysierung::Error::Strict: Class:#{klass}, DuckType:#{type[2]}, Method:#{@__error_data[:method_object]}:#{@__error_data[:method_file]}#{@__error_data[:method_name]}:#{@__error_data[:method_line]} -- called on #{@__error_data[:caller]} with #{@__error_data[:var_sym]}:#{value} of #{value.class} doesn't respond to #{type[2]}"
          end
        end
      end
      value
    end

    def get_kind(klass:)
      if klass.respond_to? :name
        splitted = klass.name.split('::')
        splitted[0] == 'Strict' ? [1, Kernel.const_get(splitted[1])] : [0, klass]
      else
        [0, klass]
      end
    end

    def set_error_data(_self:, name:, method_object:, file:, line:)
      err_data = _self.instance_variable_get :@__error_data
      err_data[:method_object] = method_object
      err_data[:method_file]   = file
      err_data[:method_name]   = name
      err_data[:method_line]   = line
      _self.instance_variable_set :@__error_data, err_data
    end
  end
end
