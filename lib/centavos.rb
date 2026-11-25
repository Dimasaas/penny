require_relative "centavos/versao"
require_relative "centavos/erros"
require_relative "centavos/rateio"
require_relative "centavos/reais"
require_relative "centavos/modulos"
require_relative "centavos/boleto"
require_relative "centavos/itf"

# Dinheiro em centavos inteiros. Float nunca entra na conta.
module Centavos
  module_function

  # Reparte +total+ (centavos) por pesos, sem perder nem criar centavo.
  #
  #   Centavos.rateio(10_000, [1, 1, 1]) # => [3334, 3333, 3333]
  def rateio(total, pesos) = Rateio.por_pesos(total, pesos)

  # Como #rateio, mas os pesos são percentuais e precisam somar 100%.
  #
  #   Centavos.rateio_percentual(10_000, ["60", "40"]) # => [6000, 4000]
  def rateio_percentual(total, percentuais) = Rateio.por_percentuais(total, percentuais)

  # 12345 -> "R$ 123,45"
  def formatar(centavos, simbolo: true) = Reais.formatar(centavos, simbolo:)

  # "R$ 1.234,56" -> 123456
  def ler(texto) = Reais.ler(texto)

  # Lê linha digitável (47) ou código de barras (44), conferindo os DVs.
  def boleto(texto) = Boleto.ler(texto)

  # Código de barras ITF do boleto, em SVG com as medidas da FEBRABAN.
  def codigo_de_barras_svg(texto) = Itf.svg(Boleto.ler(texto).barras)
end
