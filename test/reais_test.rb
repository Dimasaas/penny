require "test_helper"

class ReaisTest < Minitest::Test
  def test_formatar
    assert_equal "R$ 123,45", Tostao.formatar(12_345)
    assert_equal "R$ 0,00", Tostao.formatar(0)
    assert_equal "R$ 0,05", Tostao.formatar(5)
    assert_equal "R$ 1,00", Tostao.formatar(100)
    assert_equal "R$ 1.234.567,89", Tostao.formatar(123_456_789)
    assert_equal "R$ 1.000,00", Tostao.formatar(100_000)
  end

  def test_formatar_negativo_e_sem_simbolo
    assert_equal "-R$ 0,05", Tostao.formatar(-5)
    assert_equal "-R$ 1.234,56", Tostao.formatar(-123_456)
    assert_equal "1.234,56", Tostao.formatar(123_456, simbolo: false)
  end

  def test_formatar_recusa_nao_inteiro
    assert_raises(Tostao::ValorInvalido) { Tostao.formatar(1.5) }
    assert_raises(Tostao::ValorInvalido) { Tostao.formatar("10") }
    assert_raises(Tostao::ValorInvalido) { Tostao.formatar(nil) }
  end

  def test_ler
    assert_equal 123_456, Tostao.ler("R$ 1.234,56")
    assert_equal 123_456, Tostao.ler("1.234,56")
    assert_equal 12_345, Tostao.ler("R$123,45")
    assert_equal 5, Tostao.ler("0,05")
    assert_equal 0, Tostao.ler("R$ 0,00")
  end

  def test_ler_sem_centavos_sao_reais
    assert_equal 123_400, Tostao.ler("1234")
    assert_equal 123_400, Tostao.ler("1.234")
    assert_equal 500, Tostao.ler("R$ 5")
  end

  def test_ler_uma_casa_decimal
    assert_equal 1250, Tostao.ler("12,5")
  end

  def test_ler_negativo
    assert_equal(-500, Tostao.ler("-R$ 5,00"))
    assert_equal(-500, Tostao.ler("R$ -5,00"))
    assert_equal(-123_456, Tostao.ler("-1.234,56"))
  end

  def test_ler_entrada_invalida
    ["", "abc", "R$", ",50", "1,234", "12.50", "1.23.4", "1..234", "R$ 1,2,3",
     "--5", "-R$ -5,00", "5,00 reais", nil, 12, "1 234,56"].each do |entrada|
      assert_raises(Tostao::ValorInvalido, entrada.inspect) { Tostao.ler(entrada) }
    end
  end

  def test_ida_e_volta
    [0, 1, 99, 100, 12_345, 100_000, 123_456_789, -42, -100_000].each do |valor|
      assert_equal valor, Tostao.ler(Tostao.formatar(valor))
    end
  end

  def test_soma_em_centavos_nao_erra
    refute_equal 0.3, 0.1 + 0.2
    assert_equal 30, Tostao.ler("0,10") + Tostao.ler("0,20")
  end
end
