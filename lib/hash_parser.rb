require "ruby_parser"

# Whiltelist based hash string parser
class HashParser
  VERSION = "0.0.2"

  # a literal is strings, regex, numeric
  # https://github.com/seattlerb/ruby_parser/blob/master/lib/ruby19_parser.y#L890
  ALLOWED_CLASSES = [ :true, :false, :nil, :lit, :str, :array, :hash ].freeze

  BadHash = Class.new(StandardError)

  def safe_load(string)
    raise BadHash, "#{ string } is a bad hash" unless safe?(string)
    eval(string)
  end

  private

  def safe?(string)
    expression = RubyParser.new.parse(string)
    return false unless expression.head == :hash # root has to be a hash

    # can be optimized to do an ACTUAL_CLASSES - ALLOWED_CLASSES == []
    expression.deep_each.all? do |child|
      ALLOWED_CLASSES.include?(child.head)
    end
  end
end

