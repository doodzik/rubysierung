require 'rubysierung/version'
require 'rubysierung/types'
require 'rubysierung/core'
require 'rubysierung/ast'
require 'CallBaecker'

# This is currently works as an Adapter for Rubysierung
# @todo refactor into its own adapter module
module Rubysierung
  class << self
    include Rubysierung::Core
  end

  @__types = Rubysierung::Types.types
  # error data of the current method
  @__error_data = {}
  # default parameters of the current method
  @__defaults = {}
  @__method_data = {}

  # @todo access __type through method and make it return the types not print
  # @return [void] puts all current types
  @__types_show = -> () do
    puts @__types
  end

  # @param base [self] pointer to the class on which it is extended
  # @todo get rid of this method in order to understand the source better
  # @todo refactor into adapter
  # @return [void]
  def self.extended(base)
    # @__before_hook is called by CallBaecker inside the defined method
    #    then Rubysierung is called with the klass_hash and value_hash
    # @note This lambda is called before anything happens in a method
    # @note This is the starting point of Rubysierung.
    # @param klass_hash [Hash<Symbol, Constant>] holds types for Arguments
    # @param value_hash [Hash<Symbol, Constant>] holds values for Arguments
    # @param callee [String] first element of the current execution stack
    # @param _self [self]
    # @param name [String] name of method
    # @see CallBaecker
    # @return [self]
    base.instance_variable_set :@__before_hook, -> (klass_hash, value_hash, callee, _self, name) do
      @__error_data[:caller] = callee
      Error.set_data @__method_data[name]
      Rubysierung.call(klass_hash: klass_hash, value_hash: value_hash)
    end

    # pushes an custom type onto @__types
    # @param klass [Constant] the CustomType
    # @param standard [Symbol] the standard conversion method
    # @param strict [Symbol] the strict conversion method
    # @todo access __type through method
    # @return [self]
    base.instance_variable_set :@__add_type, -> (klass, standard, strict = standard) do
      @__types << [klass, standard, strict]
    end

    # @note This lambda is called before a method is defined inside method added
    # @param _self [self] pointer to the implementation object
    # @param name [Symbol] name of the method
    # @see CallBaecker
    # @todo get rid of :@__setup_instance_method/:@__setup_class_method
    #    and make it one
    # @return [self]
    base.instance_variable_set :@__setup_instance_method, -> (_self, name) do
      file, line = _self.instance_method(name).source_location
      ruby_str = IO.readlines(file)[line-1]
      ast = Rubysierung::AST.new(ruby_str)
      @__method_data[name] = {_self: self, name: name, method_object: _self.name, file: file, line: line}
      default_hash(ast)
    end

    # @note This lambda is called before a method is defined inside method added
    # @param _self [self] pointer to the implementation object
    # @param name [Symbol] name of the method
    # @todo get rid of :@__setup_instance_method/:@__setup_class_method
    #    and make it one
    # @see CallBaecker
    # @return [self]
    base.instance_variable_set :@__setup_class_method, -> (_self, name) do
      file, line = _self.method(name).source_location
      ruby_str = IO.readlines(file)[line-1]
      ast = Rubysierung::AST.new(ruby_str)
      @__method_data[name] = {_self: self, name: name, method_object: _self.name, file: file, line: line}
      default_hash(ast)
    end

    base.include CallBaecker
  end
end
