# Gera docs/codigo-de-barras.svg a partir de um boleto FICTÍCIO.
#
#   ruby exemplos/gerar_svg.rb
$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "tostao"

boleto = Tostao::Boleto.montar(
  banco: 999,                       # código que não pertence a nenhum banco
  valor_centavos: 123_456,          # R$ 1.234,56
  vencimento: Date.new(2026, 12, 31),
  campo_livre: "0123456789012345678901234"
)

destino = File.expand_path("../docs/codigo-de-barras.svg", __dir__)
File.write(destino, Tostao::Itf.svg(boleto.barras, titulo: "Código de barras ITF de um boleto fictício"))

puts "Linha digitável: #{boleto.linha_formatada}"
puts "Código de barras: #{boleto.barras}"
puts "Valor:            #{Tostao.formatar(boleto.valor_centavos)}"
puts "Vencimento:       #{boleto.vencimento}"
puts "SVG gravado em:   docs/codigo-de-barras.svg"
