require "minitest/autorun"
require "minitest/spec"
require "minitest/pride"
require "hash_parser"

describe HashParser do
  before do
    @parser = HashParser.new
  end

  describe "#safe_load" do
    it "fails if it is not a hash" do
      strs =  ["[]", "Book.delete_all", "puts 'hello'", '"#{puts 123}"', "system('ls /')"]
      strs.each do |bad_str|
        assert_raises HashParser::BadHash, "#{ bad_str } should not be safe" do
          @parser.safe_load(bad_str)
        end
      end
    end

    it "fails if there are more than one expression, it fails" do
      strs = ["{ :a => 1 }; 'hello'", "{ :a => 1 }\n{ :b => 2 }"]
      strs.each do |bad_str|
        assert_raises HashParser::BadHash, "#{ bad_str } should not be safe" do
          @parser.safe_load(bad_str)
        end
      end
    end

    it "Does not define or redefine any methods" do
      str = '{ :a => refine(BadHash) { def safe?; "HAHAHA"; end } }'
      assert_raises HashParser::BadHash, "#{ str } should not be safe" do
        @parser.safe_load(str)
      end

      str = '{ :a => def HashParser.safe?; "HAHAHA"; end }'
      assert_raises HashParser::BadHash, "#{ str } should not be safe" do
        @parser.safe_load(str)
      end
    end

    it "fails if it has assignment" do
      strs = ['{ :a => (HashParser::TEST_CONSTANT = 1) }',
              '{ :a => (hello_world = 1) }']
      strs.each do |str|
        assert_raises HashParser::BadHash, "#{ str } should not be safe" do
          @parser.safe_load(str)
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
              '{ :a => refine(BadHash) { def safe?; "HAHAHA"; end } }',
      ]
      strs.each do |bad_str|
        assert_raises HashParser::BadHash, "#{ bad_str } should not be safe" do
          @parser.safe_load(bad_str)
        end
      end
    end

    it "passes for hashes" do
      strs = ["{}", '{ "a" => "A" }', '{ :a => 123 }', '{ :a => true, :b => false, :c => true, "d" => nil }']
      parsed = [{}, { "a" => "A" }, { a: 123 }, { a: true, b: false, c: true, "d" => nil }]
      strs.each.with_index do |good_str, i|
        assert_equal parsed[i], @parser.safe_load(good_str), "#{ good_str } should be safe"
      end
    end

    it "passes for hashes with sub hashes" do
      str = '{ :a => [1, 2, { "x" => "y" }] }'
      parsed = { a: [1, 2, { "x" => "y" }] }
      assert_equal parsed, @parser.safe_load(str)
    end
  end
end

