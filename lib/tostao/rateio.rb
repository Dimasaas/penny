require "bigdecimal"

module Tostao
  # Repartição de um total em centavos pelo método dos maiores restos
  # (Hamilton): cada parte recebe o piso da sua cota exata, e os centavos que
  # sobram vão, um a um, para quem teve a maior fração perdida. Empate: quem
  # vem primeiro na lista. A soma das partes é sempre o total.
  module Rateio
    module_function

    # Reparte por pesos quaisquer, positivos (inteiros, racionais, decimais
    # ou textos como "33,33").
    def por_pesos(total, pesos)
      total = inteiro!(total)
      racionais = pesos_racionais(pesos)
      soma = racionais.sum

      sinal = total.negative? ? -1 : 1
      base = total.abs
      cotas = racionais.map { |p| Rational(base) * p / soma }
      partes = cotas.map(&:floor)
      sobra = base - partes.sum

      cotas.each_with_index
           .sort_by { |cota, i| [-(cota - cota.floor), i] }
           .first(sobra)
           .each { |_, i| partes[i] += 1 }

      partes.map { |parte| parte * sinal }
    end

    # Reparte por percentuais, que precisam somar exatamente 100.
    def por_percentuais(total, percentuais)
      racionais = pesos_racionais(percentuais)
      soma = racionais.sum
      unless soma == 100
        raise RateioInvalido, "os percentuais somam #{mostrar(soma)}%, e precisam somar 100%"
      end

      por_pesos(total, racionais)
    end

    def inteiro!(total)
      return total if total.is_a?(Integer)

      raise RateioInvalido, "o total precisa ser um Integer em centavos, recebi #{total.class}"
    end

    def pesos_racionais(pesos)
      lista = pesos.to_a
      raise RateioInvalido, "é preciso ao menos um peso" if lista.empty?

      lista.map do |peso|
        valor = racional(peso)
        raise RateioInvalido, "peso inválido: #{peso.inspect} (precisa ser maior que zero)" unless valor.positive?

        valor
      end
    end

    def racional(peso)
      case peso
      when Integer then Rational(peso)
      when Rational then peso
      when BigDecimal then peso.to_r
      when String then texto_para_racional(peso)
      else raise RateioInvalido, "peso inválido: #{peso.inspect} (Float não é aceito, use Rational ou texto)"
      end
    end

    # "33,33" e "33.33" valem 33,33; ponto e vírgula juntos são recusados.
    def texto_para_racional(texto)
      limpo = texto.strip.delete_suffix("%").strip
      limpo = limpo.tr(",", ".")
      raise RateioInvalido, "peso inválido: #{texto.inspect}" unless limpo.match?(/\A\d+(?:\.\d+)?\z/)

      limpo.to_r
    end

    def mostrar(valor)
      return valor.numerator.to_s if valor.denominator == 1

      format("%.4f", valor.to_f).sub(/0+\z/, "").tr(".", ",")
    end
  end
end
