require "minitest/autorun"
require "minitest/spec"
require "minitest/pride"
require "pry-byebug"
require "ruby_parser"

# Whiltelist based parser
class HashParser
  ALLOWED_CLASSES = [ :true, :false, :nil, :lit, :str, :array, :hash ].freeze

  BadHash = Class.new(StandardError)

  def safe_load(string)
    raise BadHash, "#{ string } is a bad hash" unless safe?(string)
    hash = {}
    Thread.new do
      $SAFE = 1
      hash = eval(string)
    end.join
    hash
  end

  private

  def safe?(string)
    # 1. is a hash
    # 2. everything belongs to ALLOWED_CLASSES only

    expression = RubyParser.new.parse(string)
    return false unless expression.head == :hash # root has to be a hash

    expression.deep_each.all? do |child|
      ALLOWED_CLASSES.include?(child.head)
    end
  end
end

describe HashParser do
  before do
    @parser = HashParser.new
  end

  describe "#safe_load" do
    it "fails if it is not a hash" do
      strs =  ["[]", "Label.delete_all", "puts 'hello'", '"#{puts 123}"', "system('rm -rf /')"]
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
              "{ :a => system('rm -rf /') }",
              "{ :a => Label.delete_all }",
              '{ :a => "#{500}" }',
              '{ :a => "#{ Label.delete_all }" }',
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

