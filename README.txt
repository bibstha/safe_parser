= SafeParser

home  :: https://github.com/bibstha/safe_parser
code  :: https://github.com/bibstha/safe_parser
bugs  :: https://github.com/bibstha/safe_parser

== DESCRIPTION:

Parses a ruby literal from string to its ruby value.

Eg:

```
val = SafeParser.new.safe_load('"this is a string"')
assert_equal "this is a string", val

val = SafeParser.new.safe_load(':my_symbol')
assert_equal :my_symbol, val

val = SafeParser.new.safe_load('123')
assert_equal 123, val

val = SafeParser.new.safe_load('nil')
assert_nil val

val = SafeParser.new.safe_load('true')
assert val

val = SafeParser.new.safe_load('false')
refute val

val = SafeParser.new.safe_load('[1, "my_str", :my_sym, 12.25, ["sub_array"], { test: "hash" }]')
assert_equal [1, "my_str", :my_sym, 12.25, ["sub_array"], { test: "hash" } ], val

val = SafeParser.new.safe_load('{"key_1": "value", key_2: 123}')
assert_equal {"key_1": "value", key_2: 123 }, val

# Raises exceptions when the ruby code has executable part
assert_raises(SafeParser::UnsafeError) do
  val = SafeParser.new.safe_load('{ key: "string_with_exec#{2 + 2}" }')
end

assert_raises(SafeParser::UnsafeError) do
  val = SafeParser.new.safe_load('system("ls")')
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

== INSTALL:

* Add to Gemfile: `gem 'safe_parser'`

== DEVELOPERS:

    require 'safe_parser'

    # This successfully parses the hash
    a = "{ :key_a => { :key_1a => 'value_1a', :key_2a => 'value_2a' },
           :key_b => { :key_1b => 'value_1b' } }"
    p SafeParser.new.safe_load(a)

    # This throws a SafeParser::BadHash exception
    a = "{ :key_a => system('ls') }"
    p SafeParser.new.safe_load(a)

== LICENSE:

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
