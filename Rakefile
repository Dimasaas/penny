require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test" << "lib"
  t.pattern = "test/**/*_test.rb"
  t.warning = true
end

desc "Gera docs/codigo-de-barras.svg a partir do boleto fictício"
task :exemplo do
  ruby "exemplos/gerar_svg.rb"
end

task default: :test
