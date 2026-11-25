require "test_helper"

# Todos os boletos daqui são FICTÍCIOS: banco 999 não existe e o boleto é
# montado pela própria biblioteca, só para ter DVs válidos.
class BoletoTest < Minitest::Test
  B = Tostao::Boleto

  def montar(**extra)
    B.montar(banco: 999, valor_centavos: 12_345, vencimento: Date.new(2026, 12, 31),
             campo_livre: "1234512345123451234512345", **extra)
  end

  def test_montar_gera_47_e_44_digitos
    boleto = montar
    assert_equal 47, boleto.linha.size
    assert_equal 44, boleto.barras.size
    assert_equal "999", boleto.banco
    assert_equal "9", boleto.moeda
    assert_equal 12_345, boleto.valor_centavos
    assert_equal Date.new(2026, 12, 31), boleto.vencimento(referencia: Date.new(2026, 11, 25))
  end

  def test_linha_para_barras_e_volta
    boleto = montar
    assert_equal boleto.barras, B.ler(boleto.linha).barras
    assert_equal boleto.linha, B.ler(boleto.barras).linha
  end

  def test_aceita_linha_formatada
    boleto = montar
    formatada = boleto.linha_formatada
    assert_match(/\A\d{5}\.\d{5} \d{5}\.\d{6} \d{5}\.\d{6} \d \d{14}\z/, formatada)
    assert_equal boleto.barras, B.ler(formatada).barras
  end

  def test_estrutura_das_posicoes
    boleto = montar
    assert_equal "999", boleto.barras[0, 3]
    assert_equal "9", boleto.barras[3]
    assert_equal "0000012345", boleto.barras[9, 10]
    assert_equal "1234512345123451234512345", boleto.barras[19, 25]
  end

  def test_dv_de_campo_errado_e_recusado
    linha = montar.linha.dup
    linha[9] = ((linha[9].to_i + 1) % 10).to_s
    erro = assert_raises(Tostao::BoletoInvalido) { B.ler(linha) }
    assert_match(/campo 1/, erro.message)

    linha = montar.linha.dup
    linha[31] = ((linha[31].to_i + 1) % 10).to_s
    assert_match(/campo 3/, assert_raises(Tostao::BoletoInvalido) { B.ler(linha) }.message)
  end

  def test_dv_geral_errado_e_recusado
    barras = montar.barras.dup
    barras[4] = ((barras[4].to_i + 1) % 10).to_s
    assert_match(/DV geral/, assert_raises(Tostao::BoletoInvalido) { B.ler(barras) }.message)
  end

  def test_valor_adulterado_quebra_o_dv_geral
    barras = montar.barras.dup
    barras[18] = ((barras[18].to_i + 1) % 10).to_s
    refute B.valido?(barras)
  end

  def test_tamanho_e_conteudo_invalidos
    refute B.valido?("123")
    refute B.valido?("")
    refute B.valido?(nil)
    refute B.valido?("a" * 47)
    assert_match(/47.*44/, assert_raises(Tostao::BoletoInvalido) { B.ler("1" * 45) }.message)
  end

  def test_montar_recusa_campo_livre_e_valor_ruins
    assert_raises(Tostao::BoletoInvalido) { montar(campo_livre: "123") }
    assert_raises(Tostao::BoletoInvalido) do
      B.montar(banco: 999, valor_centavos: -1, vencimento: nil, campo_livre: "0" * 25)
    end
  end

  def test_sem_vencimento_fator_zero
    boleto = B.montar(banco: 999, valor_centavos: 100, vencimento: nil, campo_livre: "0" * 25)
    assert_equal 0, boleto.fator
    assert_nil boleto.vencimento
  end

  def test_fator_de_vencimento_reinicia_em_1000
    assert_equal "1000", B.fator_do_vencimento(Date.new(1997, 10, 7) + 1000)
    assert_equal "9999", B.fator_do_vencimento(Date.new(2025, 2, 21))
    assert_equal "1000", B.fator_do_vencimento(Date.new(2025, 2, 22))
    assert_equal "1001", B.fator_do_vencimento(Date.new(2025, 2, 23))
  end

  def test_vencimento_do_fator_escolhe_o_ciclo_mais_proximo
    assert_equal Date.new(2025, 2, 22), B.vencimento_do_fator(1000, referencia: Date.new(2025, 3, 1))
    assert_equal Date.new(2000, 7, 3), B.vencimento_do_fator(1000, referencia: Date.new(2000, 8, 1))
  end

  def test_ida_e_volta_varios_boletos
    gerador = Random.new(7)
    200.times do
      boleto = B.montar(banco: gerador.rand(1..999), valor_centavos: gerador.rand(0..9_999_999_999),
                        vencimento: Date.new(2026, 1, 1) + gerador.rand(0..3000),
                        campo_livre: Array.new(25) { gerador.rand(10) }.join)
      assert_equal boleto, B.ler(boleto.linha)
      assert_equal boleto, B.ler(boleto.barras)
    end
  end
end
