# Um passeio pela biblioteca.   ruby exemplos/uso.rb
$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "centavos"

puts "0.1 + 0.2 = #{0.1 + 0.2}  (float)"
puts "10 + 20   = #{Centavos.ler('0,10') + Centavos.ler('0,20')} centavos"

partes = Centavos.rateio(10_000, [1, 1, 1])
puts "R$ 100,00 em 3: #{partes.map { |p| Centavos.formatar(p) }.join(' + ')} = #{Centavos.formatar(partes.sum)}"

begin
  Centavos.rateio_percentual(10_000, ["33,33", "33,33", "33,33"])
rescue Centavos::RateioInvalido => e
  puts "Recusado: #{e.message}"
end
