#!/usr/bin/env ruby
# Encoding: ISO-8859-1

# Amortização Price  2014.8.8
# Copyright (c) 2013 Renato Silva
# Licenciado sob os termos da GNU GPLv2

# Texto de ajuda

if [ "--help", "-h", nil ].include? ARGV[0] then puts "
    Este programa calcula o andamento de um empréstimo, feito através do
    sistema Price, baseado em amortizações adicionais específicas. Desta forma é
    possível prever como certos adiantamentos irão alterar o pagamento do
    empréstimo, especialmente o quão antecipadamente ele poderá ser quitado.\n
Modo de usar: #{File.basename($0)} <arquivo de entrada>\n
O arquivo de entrada deve ser um texto ISO-8859-1, no seguinte formato:
    Taxa: <taxa de juros>
    Parcelas: <número de parcelas>
    Saldo: <saldo devedor inicial>
    Início: <mês e ano da primeira parcela no formato mm/aaaa>
    Adiantamento mm/aaaa: <valor do adiantamento para este mês e ano>\n\n"
    exit
end

# Dados de entrada

nome_do_arquivo = ARGV[0].encode(ARGV[0].encoding, 'ISO-8859-1')
parcelas, taxa, saldo = 0
adiantamentos = {}

File.readlines(nome_do_arquivo).each do |linha|
    linha.force_encoding("ISO-8859-1")
    chave, valor = linha.strip.split(":").each { |coluna| coluna.strip! }
    next if [ chave, valor ].include? nil

    chave.downcase!
    chave.slice!(/adiantamento\s+/)

    valor.slice!(/R\$\s*/i)
    valor.slice!(/\s*%/)
    valor.gsub!(".", "")
    valor.sub!(",", ".")

    case chave
        when "parcelas"       then parcelas = valor.to_i
        when "taxa"           then taxa = 1 + (valor.to_f / 100)
        when "saldo"          then saldo = valor.to_f
        when "início"         then $inicio = valor
        when /\d+\/\d+/       then adiantamentos[chave] = valor.to_f
    end
end

# Valor da prestação e quitação de acordo com os adiantamentos

class Numeric
    def moeda
        (self * 100).round.to_f / 100
    end
    def reais
        ("R$ %.2f" % self).sub(".", ",").gsub(/(\d)(\d{3}[,$])/, "\\1.\\2")
    end
    def data
        mes_ini, ano_ini = $inicio.split("/")
        mes_ord = self + mes_ini.to_i - 2
        ano = (mes_ord / 12) + ano_ini.to_i
        mes = (mes_ord % 12 + 1).to_s.rjust(2, "0")
        "#{mes}/#{ano}"
    end
end

amortizacao = 0
prestacao = ((saldo * (taxa - 1)) / (1 - (1 / taxa ** parcelas))).moeda
printf "%3s%11s%18s%16s\n", "#", "Data", "Saldo devedor", "Amortizado"

(1..parcelas).each do |parcela|
    amortizacao = prestacao + (adiantamentos[parcela.data] or 0);
    saldo = (saldo * taxa).moeda

    amortizacao = saldo if amortizacao > saldo
    printf "%3s%11s%18s%16s\n", parcela, parcela.data, saldo.reais, amortizacao.reais

    break if amortizacao == saldo
    saldo -= amortizacao
end

puts "\nPrestação: #{prestacao.reais}"
puts "Último adiantamento efetivo: #{(amortizacao - prestacao).reais}" if amortizacao > prestacao
