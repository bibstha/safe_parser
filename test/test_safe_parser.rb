require "minitest/autorun"
require "minitest/spec"
require "minitest/pride"
require "safe_parser"

describe SafeParser do
  describe "#safe_load" do
    it "fails if it is not a hash" do
      strs =  ["Book.delete_all", "puts 'hello'", '"#{puts 123}"', "system('ls /')"]
      strs.each do |bad_str|
        assert_raises SafeParser::UnsafeError, "#{ bad_str } should not be safe" do
          SafeParser.new(bad_str).safe_load
        end
      end
    end

    it "fails if there are more than one expression" do
      strs = ["{ :a => 1 }; 'hello'", "{ :a => 1 }\n{ :b => 2 }"]
      strs.each do |bad_str|
        assert_raises SafeParser::UnsafeError, "#{ bad_str } should not be safe" do
          SafeParser.new(bad_str).safe_load
        end
      end
    end

    it "Does not define or redefine any methods" do
      str = '{ :a => refine(UnsafeError) { def safe?; "HAHAHA"; end } }'
      assert_raises SafeParser::UnsafeError, "#{ str } should not be safe" do
        SafeParser.new(str).safe_load
      end

      str = '{ :a => def SafeParser.safe?; "HAHAHA"; end }'
      assert_raises SafeParser::UnsafeError, "#{ str } should not be safe" do
        SafeParser.new(str).safe_load
      end
    end

    it "fails if it has assignment" do
      strs = ['{ :a => (SafeParser::TEST_CONSTANT = 1) }',
              '{ :a => (hello_world = 1) }']
      strs.each do |str|
        assert_raises SafeParser::UnsafeError, "#{ str } should not be safe" do
          SafeParser.new(str).safe_load
        end
      end
    end

    it "fails if a hash has a method call" do
      strs = ["{ :a => 2 * 2 }",
              "{ :a => SOME_CONST }",
              "{ :a => system('ls /') }",
              "{ :a => Book.delete_all }",
              '{ :a => "#{500}" }',
              '{ :a => "#{ Book.delete_all }" }',
              '{ :a => refine(UnsafeError) { def safe?; "HAHAHA"; end } }',
      ]
      strs.each do |bad_str|
        assert_raises SafeParser::UnsafeError, "#{ bad_str } should not be safe" do
          SafeParser.new(bad_str).safe_load
        end
      end
    end

    it "passes for hashes" do
      strs = ["{}", '{ "a" => "A" }', '{ :a => 123 }', '{ :a => true, :b => false, :c => true, "d" => nil }']
      parsed = [{}, { "a" => "A" }, { a: 123 }, { a: true, b: false, c: true, "d" => nil }]
      strs.each.with_index do |good_str, i|
        assert_equal parsed[i], SafeParser.new(good_str).safe_load, "#{ good_str } should be safe"
      end
    end

    it "passes for hashes with sub hashes" do
      str = '{ :a => [1, 2, { "x" => "y" }] }'
      parsed = { a: [1, 2, { "x" => "y" }] }
      assert_equal parsed, SafeParser.new(str).safe_load
    end

    it "passes for simple literals" do
      strs = ["1", "'a string'", ":a_symbol", "false", "true", "12.34"]
      parsed = [1, "a string", :a_symbol, false, true, 12.34]
      strs.each.with_index do |good_str, i|
        assert_equal parsed[i], SafeParser.new(good_str).safe_load, "#{ good_str } should be safe"
      end

      assert_nil SafeParser.new("nil").safe_load, "The string 'nil' should be safe"
    end

    it "passes for a complex array" do
      strs = ["[]", "['a_string', :a_symbol, true, false, nil, 1_234_567, 12.34]", "[[123], { a: 1, \"b\" => 2}]"]
      parsed = [[], ['a_string', :a_symbol, true, false, nil, 1_234_567, 12.34], [[123], { a: 1, "b" => 2}]]
      strs.each.with_index do |good_str, i|
        assert_equal parsed[i], SafeParser.new(good_str).safe_load, "#{ good_str } should be safe"
      end
    end
  end
end

