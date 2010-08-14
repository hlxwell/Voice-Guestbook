require 'test_helper'

class ThreadPostTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert ThreadPost.new.valid?
  end
end
