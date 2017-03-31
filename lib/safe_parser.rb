require "ruby_parser"

# Whiltelist based hash string parser
class SafeParser
  VERSION = "1.0.0"

  UnsafeError = Class.new(StandardError)
  attr_reader :string

  def initialize(string)
    @string = string
  end

  def safe_load
    parse(root_expression)
  end

  private

  def parse(expression)
    case expression.head
    when :hash
      Hash[*parse_into_array(expression.values)]
    when :array
      parse_into_array(expression.values)
    when :true
      true
    when :false
      false
    when :nil
      nil
    when :lit, :str
      expression.value
    else
      raise UnsafeError, "#{ string } is a bad hash"
    end
  end

  def root_expression
    @root_expression ||= RubyParser.new.parse(string)
  end

  def parse_into_array(expression)
    expression.map { |child_expression| parse(child_expression) }
  end
end
