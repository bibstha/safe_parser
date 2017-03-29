require "minitest/autorun"
require "minitest/spec"
require "minitest/pride"

require "ruby_parser"

class HashParser
  BadHash = Class.new(StandardError)

  def safe_load(string)
    raise BadHash unless safe?(string)
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
    # 2. has no method calls
    expression = RubyParser.new.parse(string)
    return false unless expression.first == :hash # root has to be a hash

    all_elements = expression.to_a.flatten
    return all_elements.all? { |element| element != :call }
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

    it "fails if a hash has a method call" do
      strs = ["{ :a => 2 * 2 }",
              "{ :a => system('rm -rf /') }",
              "{ :a => Label.delete_all }",
              '{ :a => "#{ Label.delete_all }" }']
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
        assert_equal parsed[i], @parser.safe_load(good_str)
      end
    end

    it "passes for hashes with sub hashes" do
      str = '{ :a => [1, 2, { "x" => "y" }] }'
      parsed = { a: [1, 2, { "x" => "y" }] }
      assert_equal parsed, @parser.safe_load(str)
    end
  end
end

