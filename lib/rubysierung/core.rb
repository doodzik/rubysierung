
module Rubysierung
  module Core
    def get_default_hash_from_fileline(file:, line:)
      params_matcher =  /([a-z][a-zA-Z]+):\s*([^,\n)]+)/
      def_line = IO.readlines(file)[line]
      flatten_hash = Hash[*def_line.scan(params_matcher).flatten]
      myhash = flatten_hash.reject { |k,v| v =~ /^[^A-Z]/}
      myhash.map do |(k,v)|
        const, default = v.scan(/([A-Z]\w*?)\s*\|\|\s*(.+)/).flatten
        if const && default
          myhash[k] = const
          @__defaults[k.to_sym] ||= {}
          @__defaults[k.to_sym] = default
        end
      end
      Hash[myhash.map do |(k,v)|
        [k.to_sym, Object.const_get(v)]
      end]
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
      # TODO don't use @__error_data[:var_sym]
      value = value ? value : eval(@__defaults[@__error_data[:var_sym]])
      @__types.map do |type|
        strict, klass = get_kind(klass: klass)
        begin
          if klass == type[0]
            return value.send(type[1+strict])
          end
        rescue NoMethodError
          # return argument, param, duck_type, calle/receiver -> file, line
          if strict == 0
            @__error_data.merge({klass: klass, type: type[1], value: value, value_class: value.class})
            raise Rubysierung::Error::Standart.new(@__error_data)
          else
            @__error_data.merge({klass: klass, type: type[2], value: value, value_class: value.class})
            raise Rubysierung::Error::Strict.new(@__error_data)
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
