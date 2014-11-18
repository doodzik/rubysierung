# Rubysierung

[![Build Status](https://travis-ci.org/doodzik/rubysierung.svg?branch=master)](https://travis-ci.org/doodzik/rubysierung)

Rubysierung is the type system Ruby deserves

## Installation

Add this line to your application's Gemfile:

```ruby
# ruby 2.1.0

gem 'rubysierung'
gem 'CallBaecker', '~> 0.0.3'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rubysierung

## Usage

## Have a look at all available [Types] (https://github.com/doodzik/rubysierung/blob/master/lib/rubysierung/types.rb#L3-L19)

```ruby
require 'CallBaecker'
require 'rubysierung'

# define a custom type
class CustomType
end

class Example
  extend Rubysierung
  include CallBaecker # include Callbaecker after Rubysierung

  # if the type doesnt match Rubisierung will raise an Error messages

  # add custom Types
  # [TypeClass, StandardDuckTypeAsSymbol, StrictDuckTypeAsSymbol]# TODO change to proper name
  @__add_type[CustomType, :to_s, :to_str]

  # define foo to respond to :to_s and bar to :to_i
  def one(foo: String, bar: Integer)
    [foo, bar]
  end

  # you can still define empty/default parameters
  def self.two(foo: , bar: 'hallo World')
    [foo, bar]
  end

  # use a custom type
  def self.three(foo: , bar: CustomType)
    [foo, bar]
  end

  # define foo to respond to :to_str (strict type)
  def self.four(foo: Strict::String, bar: Integer)
    [foo, bar]
  end
end
```

## what would it look like normally
```ruby
def one(foo:, bar:)
  sFoo = foo.to_s
  iBar = bar.to_i
  [sFoo, iBar]
end
```

## Contributing

1. Fork it ( https://github.com/doodzik/rubysierung/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
