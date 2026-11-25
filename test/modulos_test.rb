require "test_helper"

class ModulosTest < Minitest::Test
  M = Centavos::Modulos

  def test_modulo10_contas_a_mao
    assert_equal 0, M.modulo10("0")
    assert_equal 8, M.modulo10("1")   # 1*2 = 2
    assert_equal 1, M.modulo10("9")   # 9*2 = 18 -> 1+8 = 9
    assert_equal 5, M.modulo10("12")  # 2*2 + 1*1 = 5
    assert_equal 0, M.modulo10("123") # 3*2=6, 2*1=2, 1*2=2 -> 10 -> DV 0
  end

  def test_modulo10_soma_dos_algarismos_do_produto
    # "5": 5*2 = 10 -> 1+0 = 1 -> DV 9
    assert_equal 9, M.modulo10("5")
  end

  def test_modulo11_contas_a_mao
    assert_equal 1, M.modulo11("0")  # soma 0 -> 11 -> 1
    assert_equal 9, M.modulo11("1")  # 1*2 = 2 -> 9
    assert_equal 1, M.modulo11("5")  # 5*2 = 10 -> 11-10 = 1
    assert_equal 1, M.modulo11("6")  # 6*2 = 12 -> resto 1 -> 10 -> 1
    assert_equal 6, M.modulo11("8")  # 16 -> resto 5 -> 6
  end

  def test_modulo11_pesos_voltam_ao_2_depois_do_9
    # 9 dígitos "1": pesos 2..9 e 2 = soma 46 -> resto 2 -> DV 9
    assert_equal 9, M.modulo11("1" * 9)
  end

  def test_recusa_o_que_nao_e_digito
    assert_raises(Centavos::BoletoInvalido) { M.modulo10("12a") }
    assert_raises(Centavos::BoletoInvalido) { M.modulo11("") }
    assert_raises(Centavos::BoletoInvalido) { M.modulo10(nil) }
  end
end
