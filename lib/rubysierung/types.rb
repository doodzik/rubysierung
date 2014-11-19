
module Rubysierung::Types
  @types = [
  # Type ,     Standard, Strict
    [String,   :to_s,    :to_str],
    [Integer,  :to_i,    :to_int],
    [Array,    :to_a,    :to_ary],
    [Complex,  :to_c,    :to_c],
    [Float,    :to_f,    :to_f],
    [Hash,     :to_h,    :to_hash],
    [Rational, :to_r,    :to_r],
    # [Enum,    :to_enum, :to_enum],
    [IO,       :to_io,   :to_io],
    [Proc,     :to_proc, :to_proc],
    # [Path,    :to_path, :to_path],
    # [JSON,    :to_json, :to_json],
    [Symbol,   :to_sym,  :to_sym],
    [Thread,   :join,    :join]
  ]

  class << self
    attr_reader :types
  end
end

# Make Strict types accessible in Global namespace
module Strict
end

strict_eval = ''

Rubysierung::Types.types.map { |typ| strict_eval += "class #{typ[0]} ;end;" }
Strict.module_eval strict_eval

strict_eval = nil
