require "date"

module Centavos
  # Boleto de cobrança bancária: linha digitável (47 dígitos) e código de
  # barras (44 dígitos).
  #
  # Código de barras (posições, base 0):
  #   0..2   banco            3     moeda          4   DV geral (módulo 11)
  #   5..8   fator de venc.   9..18 valor (10)     19..43 campo livre (25)
  #
  # Linha digitável: três campos, cada um com o seu DV (módulo 10), o DV
  # geral e "fator + valor".
  #   campo 1 = banco + moeda + campo livre[0, 5]  + DV
  #   campo 2 = campo livre[5, 10]                 + DV
  #   campo 3 = campo livre[15, 10]                + DV
  module Boleto
    Dados = Data.define(:linha, :barras, :banco, :moeda, :valor_centavos, :fator, :campo_livre) do
      # Data de vencimento; o fator reinicia a cada 9000 dias, então vale a
      # data mais próxima de +referencia+.
      def vencimento(referencia: Date.today)
        Boleto.vencimento_do_fator(fator, referencia:)
      end

      def linha_formatada = Boleto.formatar_linha(linha)
    end

    BASE_DO_FATOR = Date.new(1997, 10, 7)
    CICLO = 9000

    module_function

    # Monta um boleto (linha e barras) com todos os DVs corretos.
    # Serve para exemplos e testes: nada aqui consulta banco nenhum.
    def montar(banco:, valor_centavos:, vencimento:, campo_livre:, moeda: 9)
      campo_livre = campo_livre.to_s
      raise BoletoInvalido, "o campo livre tem 25 dígitos" unless campo_livre.match?(/\A\d{25}\z/)
      raise BoletoInvalido, "valor fora de 0..9.999.999.999 centavos" unless (0..9_999_999_999).cover?(valor_centavos)

      sem_dv = format("%03d%d%s%010d%s", banco.to_i, moeda.to_i, fator_do_vencimento(vencimento),
                      valor_centavos, campo_livre)
      barras = sem_dv.dup.insert(4, Modulos.modulo11(sem_dv).to_s)
      ler(barras)
    end

    # Lê linha digitável (47) ou código de barras (44), com ou sem pontuação,
    # conferindo todos os DVs. Levanta BoletoInvalido dizendo o que falhou.
    def ler(texto)
      digitos = texto.to_s.delete(". -")
      raise BoletoInvalido, "só dígitos, pontos e espaços são aceitos" unless digitos.match?(/\A\d+\z/)

      barras, linha =
        case digitos.size
        when 47 then [barras_da_linha(digitos), digitos]
        when 44 then [conferir_barras(digitos), linha_das_barras(digitos)]
        else raise BoletoInvalido, "esperava 47 dígitos (linha) ou 44 (barras), recebi #{digitos.size}"
        end

      Dados.new(linha:, barras:, banco: barras[0, 3], moeda: barras[3], valor_centavos: barras[9, 10].to_i,
                fator: barras[5, 4].to_i, campo_livre: barras[19, 25])
    end

    def valido?(texto)
      ler(texto)
      true
    rescue BoletoInvalido
      false
    end

    # Linha de 47 dígitos -> barras de 44, validando os três DVs de campo e o DV geral.
    def barras_da_linha(linha)
      campos = [linha[0, 10], linha[10, 11], linha[21, 11]]
      campos.each_with_index do |campo, i|
        esperado = Modulos.modulo10(campo[0..-2])
        next if esperado == campo[-1].to_i

        raise BoletoInvalido, "DV do campo #{i + 1} não confere (esperava #{esperado}, veio #{campo[-1]})"
      end

      barras = linha[0, 4] + linha[32] + linha[33, 14] + linha[4, 5] + linha[10, 10] + linha[21, 10]
      conferir_barras(barras)
    end

    # Barras de 44 dígitos -> linha de 47.
    def linha_das_barras(barras)
      campo1 = barras[0, 4] + barras[19, 5]
      campo2 = barras[24, 10]
      campo3 = barras[34, 10]
      [campo1, Modulos.modulo10(campo1), campo2, Modulos.modulo10(campo2),
       campo3, Modulos.modulo10(campo3), barras[4], barras[5, 14]].join
    end

    def conferir_barras(barras)
      esperado = Modulos.modulo11(barras[0, 4] + barras[5, 39])
      return barras if esperado == barras[4].to_i

      raise BoletoInvalido, "DV geral do código de barras não confere (esperava #{esperado}, veio #{barras[4]})"
    end

    # "AAAAA.AAAAA BBBBB.BBBBBB CCCCC.CCCCCC D EEEEEEEEEEEEEE"
    def formatar_linha(linha)
      l = linha.to_s
      "#{l[0, 5]}.#{l[5, 5]} #{l[10, 5]}.#{l[15, 6]} #{l[21, 5]}.#{l[26, 6]} #{l[32]} #{l[33, 14]}"
    end

    # Dias desde 07/10/1997; passou de 9999, recomeça em 1000.
    def fator_do_vencimento(data)
      return "0000" if data.nil?

      dias = (data - BASE_DO_FATOR).to_i
      raise BoletoInvalido, "vencimento anterior à data-base do fator" if dias < 1000

      dias -= CICLO while dias > 9999
      dias.to_s.rjust(4, "0")
    end

    # Das datas que casam com o fator (uma a cada 9000 dias), a mais perto de +referencia+.
    def vencimento_do_fator(fator, referencia: Date.today)
      return nil if fator.to_i.zero?

      base = BASE_DO_FATOR + fator.to_i
      ciclos = ((referencia - base).to_f / CICLO).round
      base + (ciclos * CICLO)
    end
  end
end
