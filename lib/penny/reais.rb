module Penny
  # Formatação e leitura de valores em reais (BRL).
  module Reais
    LEITURA = /
      \A
      (?<antes>-)?\s*
      (?:R\$)?\s*
      (?<depois>-)?\s*
      (?<inteiro>\d{1,3}(?:\.\d{3})+|\d+)
      (?:,(?<decimal>\d{1,2}))?
      \z
    /x

    module_function

    # 12345 -> "R$ 123,45"; -5 -> "-R$ 0,05"
    def formatar(centavos, simbolo: true)
      unless centavos.is_a?(Integer)
        raise ValorInvalido, "esperava Integer em centavos, recebi #{centavos.class}"
      end

      reais, resto = centavos.abs.divmod(100)
      milhar = reais.to_s.reverse.scan(/\d{1,3}/).join(".").reverse
      texto = "#{milhar},#{resto.to_s.rjust(2, '0')}"
      texto = "R$ #{texto}" if simbolo
      centavos.negative? ? "-#{texto}" : texto
    end

    # "R$ 1.234,56" -> 123456; "1234" -> 123400 (sem vírgula são reais).
    # Aceita "-R$ 5,00" e "R$ -5,00". Recusa o resto.
    def ler(texto)
      raise ValorInvalido, "esperava um texto, recebi #{texto.class}" unless texto.is_a?(String)

      casou = LEITURA.match(texto.strip)
      raise ValorInvalido, "não entendi #{texto.inspect} como valor em reais" unless casou
      raise ValorInvalido, "sinal negativo duas vezes em #{texto.inspect}" if casou[:antes] && casou[:depois]

      reais = casou[:inteiro].delete(".").to_i
      centavos = casou[:decimal].to_s.ljust(2, "0").to_i
      total = (reais * 100) + centavos
      casou[:antes] || casou[:depois] ? -total : total
    end
  end
end
