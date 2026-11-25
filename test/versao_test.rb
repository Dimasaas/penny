require "test_helper"

class VersaoTest < Minitest::Test
  def test_versao_semantica
    assert_match(/\A\d+\.\d+\.\d+\z/, Penny::VERSAO)
  end
end
