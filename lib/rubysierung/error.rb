module Rubysierung
  class Error < StandardError
    # @param error_data [Hash<..>] look at message what is needed
    # @return [void]
    def initialize(error_data)
      @error_data = error_data
    end

    # @param strict [Int] 0 or 1, 1 if it strict
    # @return [Rubysierung::Error::Standard|Rubysierung::Error::Strict] instance of one of the two classes
    def raise_child(strict)
      if strict == 0
        Rubysierung::Error::Standard.new(@__error_data)
      else
        Rubysierung::Error::Strict.new(@__error_data)
      end
    end

    # @todo refactor into idependend methods and assemble them inside message
    # @return [String] error message
    def message
      "Class:#{@error_data[:klass]}, DuckType:#{@error_data[:type]}, Method:#{@error_data[:method_object]}:#{@error_data[:method_file]} #{@error_data[:method_name]}:#{@error_data[:method_line]} -- called on #{@error_data[:caller]} with #{@error_data[:var_sym]}:#{@error_data[:value]} of #{@error_data[:value_class]} doesn't respond to #{@error_data[:type]}"
    end

    # sets @__error_data on provided obj pointer
    # @param _self [self]
    # @param name [Symbol]
    # @param method_object [?]
    # @param file [String]
    # @param line [Int]
    # @return [void]
    def self.set_data(_self:, name:, method_object:, file:, line:)
      err_data = _self.instance_variable_get :@__error_data
      err_data[:method_object] = method_object
      err_data[:method_file]   = file
      err_data[:method_name]   = name
      err_data[:method_line]   = line
      _self.instance_variable_set :@__error_data, err_data
    end
  end

  class Error::Standard < Error
    # @return [String] Rubysierung::Error prefixed with self namespace
    def message
      "#{to_s}: #{super}"
    end
  end

  class Error::Strict < Error
    # @return [String] Rubysierung::Error prefixed with self namespace
    def message
      "#{to_s}: #{super}"
    end
  end
end
