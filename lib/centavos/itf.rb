module Centavos
  # Código de barras "2 de 5 intercalado" (ITF) como SVG, com as medidas da
  # FEBRABAN para o boleto: barra fina de 0,254 mm, barra larga = 3 finas,
  # altura de 13 mm e margem de silêncio de 10 finas de cada lado.
  #
  # Cada dígito são 5 elementos (2 largos, 3 finos). Os dígitos entram em
  # pares: o 1º do par vira as barras pretas, o 2º os espaços entre elas.
  # Início: barra, espaço, barra, espaço, todos finos. Fim: barra larga,
  # espaço fino, barra fina.
  module Itf
    # f = fino, L = largo; um padrão por dígito, de 0 a 9.
    PADROES = %w[ffLLf LfffL fLffL LLfff ffLfL LfLff fLLff fffLL LffLf fLfLf].freeze
    RAZAO = 3
    MARGEM = 10
    FINO_MM = 0.254
    ALTURA_MM = 13.0

    module_function

    # Lista de [preta?, largura em finos], sem a margem.
    def elementos(digitos)
      texto = digitos.to_s
      raise BoletoInvalido, "ITF pede dígitos em pares" unless texto.match?(/\A(?:\d\d)+\z/)

      inicio = [[true, 1], [false, 1], [true, 1], [false, 1]]
      meio = texto.scan(/\d\d/).flat_map do |par|
        pretas = PADROES[par[0].to_i]
        brancas = PADROES[par[1].to_i]
        (0..4).flat_map { |i| [[true, largura(pretas[i])], [false, largura(brancas[i])]] }
      end
      inicio + meio + [[true, RAZAO], [false, 1], [true, 1]]
    end

    # Largura total em finos, com as duas margens.
    def largura_em_finos(digitos)
      elementos(digitos).sum { |_, w| w } + (2 * MARGEM)
    end

    # SVG em milímetros reais (impresso a 100%, tem o tamanho da norma).
    def svg(digitos, titulo: "Código de barras ITF")
      finos = largura_em_finos(digitos)
      largura_mm = milimetros(finos)
      x = MARGEM
      retangulos = elementos(digitos).filter_map do |preta, largura|
        retangulo = %(<rect x="#{milimetros(x)}" width="#{milimetros(largura)}" height="#{milimetros_altura}"/>) if preta
        x += largura
        retangulo
      end

      <<~SVG
        <svg xmlns="http://www.w3.org/2000/svg" width="#{largura_mm}mm" height="#{milimetros_altura}mm" viewBox="0 0 #{largura_mm} #{milimetros_altura}" role="img" aria-label="#{titulo}">
          <title>#{titulo}</title>
          <rect width="#{largura_mm}" height="#{milimetros_altura}" fill="#fff"/>
          <g fill="#000" shape-rendering="crispEdges">
            #{retangulos.join("\n    ")}
          </g>
        </svg>
      SVG
    end

    def largura(letra) = letra == "L" ? RAZAO : 1

    def milimetros(finos) = (finos * FINO_MM).round(3)

    def milimetros_altura = ALTURA_MM
  end
end
