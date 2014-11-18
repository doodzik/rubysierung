module Rubysierung
  class Error < StandardError
    def initialize(error_data)
      @__error_data = error_data
    end

    def message
      "Class:#{@__error_data[:klass]}, DuckType:#{@__error_data[:type]}, Method:#{@__error_data[:method_object]}:#{@__error_data[:method_file]}#{@__error_data[:method_name]}:#{@__error_data[:method_line]} -- called on #{@__error_data[:caller]} with #{@__error_data[:var_sym]}:#{@__error_data[:value]} of #{@__error_data[:value_class]} doesn't respond to #{@__error_data[:type]}"
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
    def message(error_hash)
      "Rubysierung::Error::Standart: #{super}"
    end
  end

  class Error::Strict < Error
    def message(error_data)
      "Rubysierung::Error::Strict: #{super}"  
    end
  end
end
