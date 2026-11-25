# Um passeio pela biblioteca.   ruby exemplos/uso.rb
$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "penny"

puts "0.1 + 0.2 = #{0.1 + 0.2}  (float)"
puts "10 + 20   = #{Penny.ler('0,10') + Penny.ler('0,20')} centavos"

partes = Penny.rateio(10_000, [1, 1, 1])
puts "R$ 100,00 em 3: #{partes.map { |p| Penny.formatar(p) }.join(' + ')} = #{Penny.formatar(partes.sum)}"

begin
  Penny.rateio_percentual(10_000, ["33,33", "33,33", "33,33"])
rescue Penny::RateioInvalido => e
  puts "Recusado: #{e.message}"
end
