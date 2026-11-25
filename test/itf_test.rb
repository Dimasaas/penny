require "test_helper"

class ItfTest < Minitest::Test
  I = Tostao::Itf

  def test_largura_de_44_digitos_bate_com_a_norma
    # 22 pares x 18 finos + início (4) + fim (5) + 2 margens de 10 = 425 finos
    assert_equal 425, I.largura_em_finos("0" * 44)
    assert_in_delta 107.95, I.milimetros(425), 0.001
  end

  def test_todo_digito_tem_dois_largos_e_tres_finos
    I::PADROES.each_with_index do |padrao, digito|
      assert_equal 2, padrao.count("L"), "dígito #{digito}"
      assert_equal 3, padrao.count("f"), "dígito #{digito}"
    end
  end

  def test_inicio_e_fim
    e = I.elementos("00")
    assert_equal [[true, 1], [false, 1], [true, 1], [false, 1]], e.first(4)
    assert_equal [[true, 3], [false, 1], [true, 1]], e.last(3)
  end

  def test_pares_intercalam_pretas_e_brancas
    # "12": o 1 (LfffL) nas pretas, o 2 (fLffL) nos espaços
    meio = I.elementos("12")[4..-4]
    assert_equal [3, 1, 1, 1, 3], meio.select { |preta, _| preta }.map(&:last)
    assert_equal [1, 3, 1, 1, 3], meio.reject { |preta, _| preta }.map(&:last)
  end

  def test_recusa_impar_e_nao_digito
    assert_raises(Tostao::BoletoInvalido) { I.elementos("123") }
    assert_raises(Tostao::BoletoInvalido) { I.elementos("12ab") }
    assert_raises(Tostao::BoletoInvalido) { I.elementos("") }
  end

  def test_svg_tem_as_medidas_em_milimetros
    svg = I.svg("0" * 44)
    assert_match(/width="107.95mm"/, svg)
    assert_match(/height="13.0mm"/, svg)
    assert_match(/viewBox="0 0 107.95 13.0"/, svg)
    # a primeira barra começa depois da margem de 10 finos (2,54 mm)
    assert_match(/<rect x="2.54" width="0.254"/, svg)
  end

  def test_svg_tem_um_retangulo_por_barra_preta
    boleto = Tostao::Boleto.montar(banco: 999, valor_centavos: 100, vencimento: Date.new(2026, 12, 31),
                                     campo_livre: "1" * 25)
    svg = I.svg(boleto.barras)
    assert_equal I.elementos(boleto.barras).count { |preta, _| preta }, svg.scan(/<rect x=/).size
    assert svg.start_with?("<svg") && svg.rstrip.end_with?("</svg>")
  end
end
