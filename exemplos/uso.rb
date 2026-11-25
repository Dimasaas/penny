# Um passeio pela biblioteca.   ruby exemplos/uso.rb
$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "tostao"

puts "0.1 + 0.2 = #{0.1 + 0.2}  (float)"
puts "10 + 20   = #{Tostao.ler('0,10') + Tostao.ler('0,20')} centavos"

partes = Tostao.rateio(10_000, [1, 1, 1])
puts "R$ 100,00 em 3: #{partes.map { |p| Tostao.formatar(p) }.join(' + ')} = #{Tostao.formatar(partes.sum)}"

begin
  Tostao.rateio_percentual(10_000, ["33,33", "33,33", "33,33"])
rescue Tostao::RateioInvalido => e
  puts "Recusado: #{e.message}"
end
