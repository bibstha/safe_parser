# SafeParser

 * home  :: https://github.com/bibstha/safe_parser
 * code  :: https://github.com/bibstha/safe_parser
 * bugs  :: https://github.com/bibstha/safe_parser

## DESCRIPTION:

Parses a ruby literal from string to its ruby value.

Eg:

```
val = SafeParser.new('"this is a string"').safe_load
assert_equal "this is a string", val

val = SafeParser.new(':my_symbol').safe_load
assert_equal :my_symbol, val

val = SafeParser.new('123').safe_load
assert_equal 123, val

val = SafeParser.new('nil').safe_load
assert_nil val

val = SafeParser.new('true').safe_load
assert val

val = SafeParser.new('false').safe_load
refute val

val = SafeParser.new('[1, "my_str", :my_sym, 12.25, ["sub_array"], { test: "hash" }]').safe_load
assert_equal [1, "my_str", :my_sym, 12.25, ["sub_array"], { test: "hash" } ], val

val = SafeParser.new('{"key_1": "value", key_2: 123}').safe_load
assert_equal {"key_1": "value", key_2: 123 }, val

# Raises exceptions when the ruby code has executable part
assert_raises(SafeParser::UnsafeError) do
  val = SafeParser.new('{ key: "string_with_exec#{2 + 2}" }').safe_load
end

assert_raises(SafeParser::UnsafeError) do
  val = SafeParser.new('system("ls")').safe_load
end
```

Safe literals are any of the following:

* TrueClass
* FalseClass
* NilClass
* Numeric
* String
* Array
* Hash

Array and Hash can have any literals inside or another Array or Hash.

If the ruby code contains anything besides the literals, it throws a `SafeHash::UnsafeError` Exception.

## INSTALL:

* Add to Gemfile: `gem 'safe_parser'`

## DEVELOPERS:

    require 'safe_parser'

    # This successfully parses the hash
    a = "{ :key_a => { :key_1a => 'value_1a', :key_2a => 'value_2a' },
           :key_b => { :key_1b => 'value_1b' } }"
    p SafeParser.new(a).safe_load

    # This throws a SafeParser::BadHash exception
    a = "{ :key_a => system('ls') }"
    p SafeParser.new(a).safe_load

## LICENSE:

(The MIT License)

Copyright (c) 2017 FIX

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
