module Centavos
  # Base de todos os erros da biblioteca.
  class Erro < ArgumentError; end

  # Pesos ou percentuais que não servem para repartir um valor.
  class RateioInvalido < Erro; end

  # Texto que não é um valor em reais.
  class ValorInvalido < Erro; end

  # Linha digitável ou código de barras que não passa na conferência.
  class BoletoInvalido < Erro; end
end
