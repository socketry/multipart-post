require 'composite_io'
require 'stringio'
require 'test/unit'

class UploadIOTest < Test::Unit::TestCase
  if RUBY_VERSION >= '1.9'
    def test_works_with_ruby_192_string_ios
      assert_nothing_raised { UploadIO.new(StringIO.new, "test/content") }
    end
  end
end