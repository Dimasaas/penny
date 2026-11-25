require_relative "lib/centavos/versao"

Gem::Specification.new do |spec|
  spec.name = "centavos"
  spec.version = Centavos::VERSAO
  spec.authors = ["João Victor Diamantino Cardoso"]
  spec.email = ["80987512+Dimasaas@users.noreply.github.com"]

  spec.summary = "Dinheiro em centavos inteiros: rateio sem perder centavo, BRL e boleto."
  spec.description = "Rateio pelo método dos maiores restos, formatação e leitura de reais, " \
                     "módulos 10 e 11 da FEBRABAN, linha digitável de boleto e código de barras ITF em SVG. " \
                     "Sem dependências de runtime."
  spec.homepage = "https://github.com/Dimasaas/centavos"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.files = Dir["lib/**/*.rb", "LICENSE", "README.md"]
  spec.require_paths = ["lib"]
  spec.metadata["rubygems_mfa_required"] = "true"
end
