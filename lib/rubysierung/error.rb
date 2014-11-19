module Rubysierung
  class Error < StandardError
    def initialize(error_data)
      @error_data = error_data
    end

    def raise_child(strict)
      if strict == 0
        Rubysierung::Error::Standard.new(@__error_data)
      else
        Rubysierung::Error::Strict.new(@__error_data)
      end
    end

    # TODO: refactor into idependend methods and assemble them inside message 
    def message
      "Class:#{@error_data[:klass]}, DuckType:#{@error_data[:type]}, Method:#{@error_data[:method_object]}:#{@error_data[:method_file]} #{@error_data[:method_name]}:#{@error_data[:method_line]} -- called on #{@error_data[:caller]} with #{@error_data[:var_sym]}:#{@error_data[:value]} of #{@error_data[:value_class]} doesn't respond to #{@error_data[:type]}"
    end

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
    def message
      "Rubysierung::Error::Standard: #{super}"
    end
  end

  class Error::Strict < Error
    def message
      "Rubysierung::Error::Strict: #{super}"
    end
  end
end
