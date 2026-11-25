module Penny
  # Dígitos verificadores da FEBRABAN. Recebem só dígitos (String) e
  # devolvem o DV como Integer.
  module Modulos
    module_function

    # Módulo 10: pesos 2, 1, 2, 1... da direita para a esquerda; cada produto
    # com dois algarismos tem os algarismos somados (18 vira 1 + 8).
    def modulo10(digitos)
      soma = conferir(digitos).reverse.each_char.with_index.sum do |c, i|
        produto = c.to_i * (i.even? ? 2 : 1)
        produto > 9 ? produto - 9 : produto
      end
      (10 - (soma % 10)) % 10
    end

    # Módulo 11 do código de barras de cobrança: pesos 2 a 9 da direita para a
    # esquerda, repetindo. DV = 11 - resto; resultado 0, 10 ou 11 vira 1.
    def modulo11(digitos)
      soma = conferir(digitos).reverse.each_char.with_index.sum { |c, i| c.to_i * ((i % 8) + 2) }
      dv = 11 - (soma % 11)
      [0, 10, 11].include?(dv) ? 1 : dv
    end

    def conferir(digitos)
      texto = digitos.to_s
      raise BoletoInvalido, "esperava só dígitos, recebi #{digitos.inspect}" unless texto.match?(/\A\d+\z/)

      texto
    end
  end
end
