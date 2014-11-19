require 'rubysierung/version'
require 'rubysierung/types'
require 'rubysierung/error'
require 'rubysierung/core'
require 'CallBaecker'

module Rubysierung
  class << self
    include Rubysierung::Core
  end

  @__types = Rubysierung::Types.types
  @__error_data = {}
  @__defaults = {}

  def self.extended(base)
    # TODO: access __type through method
    base.instance_variable_set :@__types_show, -> () do
      puts @__types
    end

    base.instance_variable_set :@__add_type, -> (klass, standard, strict) do
      @__types << [klass, standard, strict]
    end

    base.instance_variable_set :@__before_hook, -> (klass_hash, value_hash, callee) do
      @__error_data[:caller] = callee
      Rubysierung.call(klass_hash: klass_hash, value_hash: value_hash)
    end

    base.instance_variable_set :@__setup_instance_method, -> (_self, name) do
      file, line = _self.instance_method(name.to_sym).source_location
      Error.set_data(_self: self, name: name, method_object: _self.name, file: file, line: line - 1)
      get_default_hash_from_fileline(file: file, line: line - 1)
    end

    base.instance_variable_set :@__setup_class_method, -> (_self, name) do
      file, line = _self.method(name.to_sym).source_location
      Error.set_data(_self: self, name: name, method_object: _self.name, file: file, line: line - 1)
      get_default_hash_from_fileline(file: file, line: line - 1)
    end

    base.include CallBaecker
  end
end
