require "test_helper"

class ReaisTest < Minitest::Test
  def test_formatar
    assert_equal "R$ 123,45", Centavos.formatar(12_345)
    assert_equal "R$ 0,00", Centavos.formatar(0)
    assert_equal "R$ 0,05", Centavos.formatar(5)
    assert_equal "R$ 1,00", Centavos.formatar(100)
    assert_equal "R$ 1.234.567,89", Centavos.formatar(123_456_789)
    assert_equal "R$ 1.000,00", Centavos.formatar(100_000)
  end

  def test_formatar_negativo_e_sem_simbolo
    assert_equal "-R$ 0,05", Centavos.formatar(-5)
    assert_equal "-R$ 1.234,56", Centavos.formatar(-123_456)
    assert_equal "1.234,56", Centavos.formatar(123_456, simbolo: false)
  end

  def test_formatar_recusa_nao_inteiro
    assert_raises(Centavos::ValorInvalido) { Centavos.formatar(1.5) }
    assert_raises(Centavos::ValorInvalido) { Centavos.formatar("10") }
    assert_raises(Centavos::ValorInvalido) { Centavos.formatar(nil) }
  end

  def test_ler
    assert_equal 123_456, Centavos.ler("R$ 1.234,56")
    assert_equal 123_456, Centavos.ler("1.234,56")
    assert_equal 12_345, Centavos.ler("R$123,45")
    assert_equal 5, Centavos.ler("0,05")
    assert_equal 0, Centavos.ler("R$ 0,00")
  end

  def test_ler_sem_centavos_sao_reais
    assert_equal 123_400, Centavos.ler("1234")
    assert_equal 123_400, Centavos.ler("1.234")
    assert_equal 500, Centavos.ler("R$ 5")
  end

  def test_ler_uma_casa_decimal
    assert_equal 1250, Centavos.ler("12,5")
  end

  def test_ler_negativo
    assert_equal(-500, Centavos.ler("-R$ 5,00"))
    assert_equal(-500, Centavos.ler("R$ -5,00"))
    assert_equal(-123_456, Centavos.ler("-1.234,56"))
  end

  def test_ler_entrada_invalida
    ["", "abc", "R$", ",50", "1,234", "12.50", "1.23.4", "1..234", "R$ 1,2,3",
     "--5", "-R$ -5,00", "5,00 reais", nil, 12, "1 234,56"].each do |entrada|
      assert_raises(Centavos::ValorInvalido, entrada.inspect) { Centavos.ler(entrada) }
    end
  end

  def test_ida_e_volta
    [0, 1, 99, 100, 12_345, 100_000, 123_456_789, -42, -100_000].each do |valor|
      assert_equal valor, Centavos.ler(Centavos.formatar(valor))
    end
  end

  def test_soma_em_centavos_nao_erra
    refute_equal 0.3, 0.1 + 0.2
    assert_equal 30, Centavos.ler("0,10") + Centavos.ler("0,20")
  end
end
