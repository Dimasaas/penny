require "test_helper"

class RateioTest < Minitest::Test
  def test_cem_reais_em_tres_partes_iguais
    assert_equal [3334, 3333, 3333], Centavos.rateio(10_000, [1, 1, 1])
  end

  def test_soma_sempre_bate
    gerador = Random.new(42)
    1000.times do
      total = gerador.rand(0..5_000_000)
      pesos = Array.new(gerador.rand(1..12)) { gerador.rand(1..9999) }
      partes = Centavos.rateio(total, pesos)

      assert_equal total, partes.sum, "total #{total} pesos #{pesos}"
      assert_equal pesos.size, partes.size
      assert(partes.all? { |p| p >= 0 })
    end
  end

  def test_proporcional_quando_divide_exato
    assert_equal [6000, 4000], Centavos.rateio(10_000, [3, 2])
  end

  def test_maior_resto_ganha_o_centavo
    # 101 em [1, 2, 2]: cotas 20,2 / 40,4 / 40,4 -> sobra 1, vai para o 2o (empate dos restos .4)
    assert_equal [20, 41, 40], Centavos.rateio(101, [1, 2, 2])
    # 10 em [1, 1, 8]: cotas 1,0 / 1,0 / 8,0 exatas
    assert_equal [1, 1, 8], Centavos.rateio(10, [1, 1, 8])
    # 10 em [3, 3, 4] -> 3,0 / 3,0 / 4,0 ; 7 em [3, 3, 4] -> 2,1 / 2,1 / 2,8 : o resto .8 leva
    assert_equal [2, 2, 3], Centavos.rateio(7, [3, 3, 4])
  end

  def test_empate_favorece_o_primeiro_da_lista
    assert_equal [1, 0, 0], Centavos.rateio(1, [1, 1, 1])
    assert_equal [2, 2, 1], Centavos.rateio(5, [1, 1, 1])
  end

  def test_total_zero
    assert_equal [0, 0], Centavos.rateio(0, [1, 1])
  end

  def test_total_negativo_espelha_o_positivo
    assert_equal [-3334, -3333, -3333], Centavos.rateio(-10_000, [1, 1, 1])
  end

  def test_um_peso_so_leva_tudo
    assert_equal [777], Centavos.rateio(777, [5])
  end

  def test_pesos_em_texto_e_racional
    assert_equal [5000, 5000], Centavos.rateio(10_000, ["50,0", Rational(50)])
  end

  def test_recusa_peso_invalido
    assert_raises(Centavos::RateioInvalido) { Centavos.rateio(100, []) }
    assert_raises(Centavos::RateioInvalido) { Centavos.rateio(100, [1, 0]) }
    assert_raises(Centavos::RateioInvalido) { Centavos.rateio(100, [1, -1]) }
    assert_raises(Centavos::RateioInvalido) { Centavos.rateio(100, [0.5, 0.5]) }
    assert_raises(Centavos::RateioInvalido) { Centavos.rateio(100, ["abc"]) }
    assert_raises(Centavos::RateioInvalido) { Centavos.rateio(1.5, [1]) }
  end

  def test_percentuais_que_somam_cem
    assert_equal [3334, 3333, 3333], Centavos.rateio_percentual(10_000, ["33,34", "33,33", "33,33"])
    assert_equal [6000, 4000], Centavos.rateio_percentual(10_000, [60, 40])
  end

  def test_percentuais_que_nao_somam_cem_dao_erro_claro
    erro = assert_raises(Centavos::RateioInvalido) do
      Centavos.rateio_percentual(10_000, ["33,33", "33,33", "33,33"])
    end
    assert_match(/somam 99,99%.*100%/, erro.message)

    erro = assert_raises(Centavos::RateioInvalido) { Centavos.rateio_percentual(10_000, [60, 50]) }
    assert_match(/somam 110%/, erro.message)
  end
end
