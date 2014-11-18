module Rubysierung::Core
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
            raise Rubysierung::Error::Standart, "Rubysierung::Error::Standart: Class:#{klass}, DuckType:#{type[2]}, Method:#{@__error_data[:method_object]}:#{@__error_data[:method_file]}#{@__error_data[:method_name]}:#{@__error_data[:method_line]} -- called on #{@__error_data[:caller]} with #{@__error_data[:var_sym]}:#{value} of #{value.class} doesn't respond to #{type[2]}"
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
