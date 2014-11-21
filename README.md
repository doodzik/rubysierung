# Rubysierung

[![Build Status](https://travis-ci.org/doodzik/rubysierung.svg?branch=master)](https://travis-ci.org/doodzik/rubysierung)

Rubysierung is an implementation of Conversion Typing in Ruby


## Installation

Add this line to your application's Gemfile:

```ruby
# ruby 2.1.0
# You can only use Rubysierung in a file context, see issue #5 and #7.
gem 'rubysierung'
```
if you installed rubysierung from rubygems please consider looking at the instructions for its version
https://github.com/doodzik/rubysierung/tree/0.0.2

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rubysierung

## Usage

## Have a look at all available [Types] (https://github.com/doodzik/rubysierung/blob/master/lib/rubysierung/types.rb#L3-L19)

```ruby
require 'rubysierung'

# define a custom types
class Strict::CustomTyp;end
class CustomTyp;end

class Strict::CustomTypX;end
class CustomTypX;end

class Example
  extend Rubysierung

  # if the type doesnt match Rubisierung will raise an Error messages

  # add custom Types
  # if you don't specify a Strict Type the standard type is being set for it
  # [TypeClass, StandardConversionMethodAsSymbol, StrictConversionMethodSymbol]
  @__add_type[CustomType, :to_s, :to_str]
  @__add_type[CustomTypeX, :to_s]

  # define foo to respond to :to_s and bar to :to_i
  def one(foo: String, bar: Integer)
    [foo, bar]
  end

  # you can still define empty/default parameters
  def self.two(foo:, bar: 'hallo World')
    [foo, bar]
  end

  # use a custom type
  def self.three(foo:, bar: CustomType)
    [foo, bar]
  end

  # define foo to respond to :to_str (strict type)
  def self.four(foo: Strict::String, bar: Integer)
    [foo, bar]
  end

  # with default parameters
  def self.five(foo: String||'I am a default :)', bar: Integer||42)
    [foo, bar]
  end
end
```

## what it would look like normally
```ruby
def one(foo:, bar:)
  sFoo = foo.to_s
  iBar = bar.to_i
  [sFoo, iBar]
end
```

## Other static Typing implementations
https://github.com/hannestyden/typo/blob/master/typo.rb

## Contributing

1. Fork it ( https://github.com/doodzik/rubysierung/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
