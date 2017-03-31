require "ruby_parser"

# Whiltelist based hash string parser
class HashParser
  VERSION = "0.0.2"

  # a literal is strings, regex, numeric
  # https://github.com/seattlerb/ruby_parser/blob/master/lib/ruby19_parser.y#L890
  ALLOWED_CLASSES = [ :true, :false, :nil, :lit, :str, :array, :hash ].freeze

  BadHash = Class.new(StandardError)
  attr_reader :string

  def initialize(string)
    @string = string
  end

  def safe_load
    raise BadHash, "#{ string } is a bad hash" unless safe?
    eval(string)
  end

  private

  def expressions
    @expressions ||= RubyParser.new.parse(string)
  end

  def safe?
    return false unless ALLOWED_CLASSES.include?(expressions.head)

    # deep_each will start from the second node, so we need to validte the head
    # first by itself.
    expressions.deep_each.all? do |expression|
      ALLOWED_CLASSES.include?(expression.head)
    end
  end
end
