require 'find'
require 'event_source_public'

if ARGV.length < 2
  puts "Use >ruby test.rb <login> <password>"
end

esource = MoneyTrackin.new

tags = "расходники, сервис, штрафы, шиномонтаж, колеса, платежи, инструмент, поломки, запчасти, аксесуары, бензин, автомобиль"

esource.configure(login: ARGV[0], password: ARGV[1], tags_to_import: tags)

esource.fetch(esource.password)
