
module Rubysierung
  module Core
    def get_default_hash_from_fileline(file:, line:)
      params_matcher =  /([a-z][a-zA-Z]+):\s*([^,\n)]+)/
      def_line = IO.readlines(file)[line]
      flatten_hash = Hash[*def_line.scan(params_matcher).flatten]
      myhash = flatten_hash.reject { |_, v| v =~ /^[^A-Z]/ }
      myhash.map do |k, v|
        const, default = v.scan(/([A-Z]\w*?)\s*\|\|\s*(.+)/).flatten
        next unless const && default
        myhash[k] = const
        @__defaults[k.to_sym] ||= {}
        @__defaults[k.to_sym] = default
      end
      Hash[myhash.map do |k, v|
        [k.to_sym, Kernel.const_get(v)]
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
      # TODO: don't use @__error_data[:var_sym]
      value = value ? value : eval(@__defaults[@__error_data[:var_sym]])
      @__types.map do |type|
        strict, klass = get_kind(klass: klass)
        klass == type[0] and return value.send(type[1 + strict])
      end
      value
    rescue NoMethodError
      @__error_data.merge({ klass: klass, type: type[1 + strict], value: value, value_class: value.class })
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
  end
end
