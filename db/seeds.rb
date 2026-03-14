# frozen_string_literal: true

# Seeds para popular o banco com dados de teste
# Execute: bin/rails db:seed
#
# Credenciais de acesso:
# ----------------------
# Tenant 1 (agronna):     admin@agronna.local     / Senha@123
# Tenant 2 (fazendaboa):  admin@fazendaboa.local  / Senha@123
# Tenant 3 (ruraltech):   admin@ruraltech.local   / Senha@123

puts "🌱 Iniciando seeds..."

# ==============================================================================
# LIMPEZA (apenas em desenvolvimento)
# ==============================================================================

if Rails.env.development?
  puts "\n🧹 Limpando dados antigos..."
  # Ordem importante devido às foreign keys
  ServiceOrderMachine.delete_all
  ServiceOrder.unscoped.delete_all
  Address.delete_all
  ServiceProvider.unscoped.delete_all
  Machine.unscoped.delete_all
  Property.unscoped.delete_all
  Producer.unscoped.delete_all
  # Remove owner_id reference before deleting users
  Tenant.update_all(owner_id: nil)
  User.unscoped.delete_all
  Secretary.unscoped.delete_all
  Tenant.delete_all
  Audited::Audit.delete_all
  puts "  ✅ Dados removidos"
end

# Desabilitar auditing durante o seed para evitar problemas de serialização
Audited.auditing_enabled = false

# ==============================================================================
# DADOS BASE
# ==============================================================================

MUNICIPIOS = [
  "São Paulo", "Ribeirão Preto", "Campinas", "Sorocaba", "Piracicaba",
  "Uberlândia", "Uberaba", "Goiânia", "Anápolis", "Rio Verde"
].freeze

ATIVIDADES = [
  "Cultivo de soja", "Cultivo de milho", "Pecuária de corte", "Pecuária leiteira",
  "Cultivo de café", "Cultivo de cana-de-açúcar", "Fruticultura", "Horticultura",
  "Avicultura", "Suinocultura"
].freeze

FUNCOES_MAQUINAS = [
  "Trator", "Colheitadeira", "Pulverizador", "Plantadeira", "Grade aradora",
  "Carreta agrícola", "Roçadeira", "Subsolador", "Adubadeira", "Irrigação"
].freeze

TIPOS_SERVICO = [
  "Manutenção de máquinas", "Transporte agrícola", "Consultoria agronômica",
  "Topografia", "Análise de solo", "Pulverização aérea", "Veterinária",
  "Contabilidade rural", "Assessoria jurídica", "Irrigação"
].freeze

# ==============================================================================
# HELPER METHODS
# ==============================================================================

def gerar_cpf(seed_number)
  base = seed_number.to_s.rjust(9, "0")[0..8]
  numeros = base.chars.map(&:to_i)
  2.times do
    soma = numeros.each_with_index.sum { |n, i| n * (numeros.size + 1 - i) }
    resto = soma % 11
    numeros << (resto < 2 ? 0 : 11 - resto)
  end
  numeros.join
end

def gerar_cnpj(seed_number)
  base = seed_number.to_s.rjust(8, "0")[0..7]
  numeros = base.chars.map(&:to_i) + [ 0, 0, 0, 1 ]
  pesos1 = [ 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2 ]
  soma = numeros.each_with_index.sum { |n, idx| n * pesos1[idx] }
  resto = soma % 11
  numeros << (resto < 2 ? 0 : 11 - resto)
  pesos2 = [ 6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2 ]
  soma = numeros.each_with_index.sum { |n, idx| n * pesos2[idx] }
  resto = soma % 11
  numeros << (resto < 2 ? 0 : 11 - resto)
  numeros.join
end

def gerar_telefone
  "(#{rand(11..99)}) 9#{rand(1000..9999)}-#{rand(1000..9999)}"
end

def gerar_placa
  "#{('A'..'Z').to_a.sample(3).join}#{rand(0..9)}#{('A'..'Z').to_a.sample(1).join}#{rand(10..99)}"
end

def gerar_chassi
  "9B#{('A'..'Z').to_a.sample(2).join}#{rand(100000..999999)}#{rand(100000..999999)}"
end

NOMES_RUAS = [
  "das Flores", "Brasil", "São Paulo", "Principal", "da Paz", "das Acácias",
  "dos Ipês", "do Comércio", "15 de Novembro", "7 de Setembro", "Dom Pedro",
  "Getúlio Vargas", "JK", "Santos Dumont", "Tiradentes", "da Liberdade"
].freeze

def criar_endereco(addressable)
  Address.find_or_create_by!(addressable: addressable) do |a|
    a.street = [ "Rua", "Avenida", "Alameda", "Travessa" ].sample + " " + NOMES_RUAS.sample
    a.number = rand(1..9999).to_s
    a.complement = [ "Sala #{rand(1..50)}", "Bloco #{('A'..'F').to_a.sample}", nil ].sample
    a.neighborhood = [ "Centro", "Jardim América", "Vila Nova", "Parque Industrial" ].sample
    a.city = MUNICIPIOS.sample
    a.state = [ "SP", "MG", "GO", "MT", "MS", "PR" ].sample
    a.zip_code = "#{rand(10000..99999)}-#{rand(100..999)}"
    a.country = "BR"
  end
end

# ==============================================================================
# CONFIGURAÇÃO DOS TENANTS
# ==============================================================================

TENANTS_CONFIG = [
  {
    subdomain: "agronna",
    name: "Agronna Agronegócios",
    secretaries: [
      { name: "Secretaria Municipal de Agricultura", prefecture: "Ribeirão Preto" },
      { name: "Secretaria de Meio Ambiente", prefecture: "Campinas" }
    ],
    users_count: 15,
    producers_count: 20,
    machines_count: 12,
    service_providers_count: 8
  },
  {
    subdomain: "fazendaboa",
    name: "Fazenda Boa Vista",
    secretaries: [
      { name: "Secretaria de Agropecuária", prefecture: "Uberlândia" },
      { name: "Secretaria de Recursos Hídricos", prefecture: "Uberaba" }
    ],
    users_count: 8,
    producers_count: 12,
    machines_count: 8,
    service_providers_count: 5
  },
  {
    subdomain: "ruraltech",
    name: "RuralTech Soluções",
    secretaries: [
      { name: "Secretaria de Desenvolvimento Rural", prefecture: "Goiânia" },
      { name: "Secretaria de Inovação Agrícola", prefecture: "Anápolis" },
      { name: "Secretaria de Sustentabilidade", prefecture: "Rio Verde" }
    ],
    users_count: 25,
    producers_count: 30,
    machines_count: 20,
    service_providers_count: 15
  }
].freeze

# ==============================================================================
# CRIAÇÃO DOS DADOS
# ==============================================================================

TENANTS_CONFIG.each do |config|
  puts "\n📦 Criando tenant: #{config[:name]} (#{config[:subdomain]})"

  # Criar Tenant
  tenant = Tenant.find_or_create_by!(subdomain: config[:subdomain]) do |t|
    t.name = config[:name]
  end

  # Criar Secretarias
  tenant_offset = Tenant.where("id < ?", tenant.id).count * 1000
  secretaries = config[:secretaries].map.with_index do |sec_config, idx|
    cnpj_seed = tenant_offset + 100 + idx
    Secretary.unscoped.find_or_create_by!(tenant: tenant, email: "secretaria#{idx + 1}@#{config[:subdomain]}.local") do |s|
      s.name = sec_config[:name]
      s.corporate_name = "#{sec_config[:name]} - #{sec_config[:prefecture]}"
      s.cnpj = gerar_cnpj(cnpj_seed)
      s.prefecture_name = sec_config[:prefecture]
      s.status = :active
    end.tap { |sec| criar_endereco(sec) }
  end
  puts "  ✅ #{secretaries.size} secretaria(s)"

  primary_secretary = secretaries.first

  # Criar Admin
  admin = User.unscoped.find_or_create_by!(email: "admin@#{config[:subdomain]}.local", tenant: tenant) do |u|
    u.name = "Administrador #{config[:name]}"
    u.password = "Senha@123"
    u.role = :admin
    u.secretary = primary_secretary
  end
  admin.update_columns(secretary_id: primary_secretary.id) if admin.secretary_id.blank?
  tenant.update_column(:owner_id, admin.id) if tenant.owner_id.blank?

  # Criar Sub-admin
  User.unscoped.find_or_create_by!(email: "subadmin@#{config[:subdomain]}.local", tenant: tenant) do |u|
    u.name = "Sub-Administrador"
    u.password = "Senha@123"
    u.role = :sub_admin
    u.secretary = primary_secretary
  end

  # Criar Usuários comuns
  config[:users_count].times do |i|
    User.unscoped.find_or_create_by!(email: "usuario#{i + 1}@#{config[:subdomain]}.local", tenant: tenant) do |u|
      u.name = "Usuário #{i + 1}"
      u.password = "Senha@123"
      u.role = :user
      u.secretary = secretaries.sample
    end
  end
  puts "  ✅ #{config[:users_count] + 2} usuário(s)"

  # Criar Produtores
  producers = config[:producers_count].times.map do |i|
    cpf_seed = tenant_offset + 200 + i
    Producer.unscoped.find_or_create_by!(tenant: tenant, email: "produtor#{i + 1}@#{config[:subdomain]}.local") do |p|
      p.name = "Produtor #{i + 1} - #{config[:subdomain].capitalize}"
      p.cpf = gerar_cpf(cpf_seed)
      p.phone = gerar_telefone
      p.birth_date = Date.new(1950 + (i % 45), (i % 12) + 1, (i % 28) + 1)
      p.status = i % 4 == 0 ? :inactive : :active
    end.tap { |prod| criar_endereco(prod) }
  end
  puts "  ✅ #{producers.size} produtor(es)"

  # Criar Propriedades (1-2 por produtor)
  properties_count = 0
  producers.each_with_index do |producer, prod_idx|
    num_props = (prod_idx % 2) + 1
    num_props.times do |i|
      Property.unscoped.find_or_create_by!(
        tenant: tenant,
        producer: producer,
        name: "Propriedade #{i + 1} de #{producer.name.split(' - ').first}"
      ) do |p|
        ativ_idx = (prod_idx + i) % ATIVIDADES.size
        p.activity = ATIVIDADES[ativ_idx..(ativ_idx + 1)].join(", ")
        p.incra = "#{(tenant_offset + 300 + prod_idx * 10 + i).to_s.rjust(6, '0')}.#{(100000 + prod_idx)}"
        p.registration = "MAT-#{(10000 + prod_idx * 10 + i)}/#{2015 + (prod_idx % 10)}"
        p.localization = "#{MUNICIPIOS[prod_idx % MUNICIPIOS.size]}, Zona Rural Km #{prod_idx + i + 1}"
        p.status = (prod_idx + i) % 3 == 0 ? :inactive : :active
      end.tap { |prop| criar_endereco(prop) }
      properties_count += 1
    end
  end
  puts "  ✅ #{properties_count} propriedade(s)"

  # Criar Maquinários
  marcas = %w[John\ Deere Massey\ Ferguson New\ Holland Case\ IH Valtra]
  config[:machines_count].times do |i|
    chassi = "9B#{config[:subdomain][0..1].upcase}#{(tenant_offset + 400 + i).to_s.rjust(12, '0')}"
    funcao = FUNCOES_MAQUINAS[i % FUNCOES_MAQUINAS.size]
    Machine.unscoped.find_or_create_by!(tenant: tenant, chassis: chassi) do |m|
      m.name = "#{funcao} #{marcas[i % marcas.size]}"
      m.plate = "#{config[:subdomain][0..2].upcase}#{i}A#{(10 + i).to_s.rjust(2, '0')}"
      m.manufacturing_year = 2015 + (i % 10)
      m.function = funcao
      m.secretary = secretaries[i % secretaries.size]
      m.status = i % 3 == 0 ? :inactive : :active
    end
  end
  puts "  ✅ #{config[:machines_count]} maquinário(s)"

  # Criar Prestadores de Serviço
  service_providers_list = config[:service_providers_count].times.map do |i|
    cnpj_seed = tenant_offset + 500 + i
    tipo = TIPOS_SERVICO[i % TIPOS_SERVICO.size]
    sufixos = %w[Express Premium Total Plus Pro]
    ServiceProvider.unscoped.find_or_create_by!(tenant: tenant, email: "contato#{i + 1}@prestador#{config[:subdomain]}.local") do |sp|
      sp.name = "#{tipo.split.first} #{sufixos[i % sufixos.size]}"
      sp.corporate_name = "#{sp.name} Ltda"
      sp.cnpj = gerar_cnpj(cnpj_seed)
      sp.telephone = gerar_telefone
      sp.service_type = tipo
      sp.secretary = secretaries[i % secretaries.size]
      sp.status = i % 3 == 0 ? :inactive : :active
    end.tap { |sp| criar_endereco(sp) }
  end
  puts "  ✅ #{config[:service_providers_count]} prestador(es) de serviço"

  # Criar Ordens de Serviço
  titulos_os = [
    "Manutenção preventiva de equipamento",
    "Preparo de solo para plantio",
    "Aplicação de defensivos agrícolas",
    "Colheita mecanizada",
    "Reparo de cerca perimetral",
    "Limpeza de área de pastagem",
    "Instalação de sistema de irrigação",
    "Manutenção corretiva de trator",
    "Análise de solo",
    "Consultoria técnica agronômica"
  ]
  statuses_os = %i[pending scheduled in_progress completed cancelled]
  priorities_os = %i[low normal high urgent]

  machines_list = Machine.unscoped.where(tenant: tenant).to_a
  properties_list = Property.unscoped.where(tenant: tenant).to_a
  users_list = User.unscoped.where(tenant: tenant).to_a

  service_orders_count = [ config[:producers_count], 15 ].min
  service_orders_count.times do |i|
    ServiceOrder.unscoped.find_or_create_by!(tenant: tenant, code: format("OS-%d-%04d", Date.current.year, i + 1)) do |so|
      so.title = titulos_os[i % titulos_os.size]
      so.description = "Descrição detalhada da ordem de serviço ##{i + 1}. Incluir todos os procedimentos necessários."
      so.deadline = Date.current + (i % 30).days - 5.days
      so.scheduled_at = i % 3 == 0 ? (Time.current + (i % 14).days) : nil
      so.status = statuses_os[i % statuses_os.size]
      so.priority = priorities_os[i % priorities_os.size]
      so.observations = i % 2 == 0 ? "Observação importante para esta OS." : nil
      so.secretary = secretaries[i % secretaries.size]
      so.property = properties_list[i % properties_list.size] if properties_list.any? && i % 2 == 0
      so.producer = producers[i % producers.size] if producers.any? && i % 3 == 0
      so.service_provider = service_providers_list[i % service_providers_list.size] if service_providers_list.any? && i % 4 == 0
      so.assigned_to = users_list[i % users_list.size] if users_list.any?
      so.requested_by = users_list.first
      so.started_at = Time.current - (10 - i).days if so.status.to_s.in?(%w[in_progress completed])
      so.completed_at = Time.current - (5 - i).days if so.status == :completed
    end.tap do |so|
      if machines_list.any? && so.machines.empty?
        num_machines = (i % 3) + 1
        selected_machines = machines_list.sample(num_machines)
        selected_machines.each do |machine|
          ServiceOrderMachine.find_or_create_by!(service_order: so, machine: machine) do |som|
            som.hours_used = [ 2.5, 4.0, 8.0, 12.0, nil ].sample
            som.notes = i % 2 == 0 ? "Utilizado conforme especificação." : nil
          end
        end
      end
    end
  end
  puts "  ✅ #{service_orders_count} ordem(ns) de serviço"
end

# ==============================================================================
# RESUMO FINAL
# ==============================================================================

puts "\n" + "=" * 60
puts "🎉 Seeds concluídos com sucesso!"
puts "=" * 60
puts "\n📊 Resumo:"
puts "   Tenants:              #{Tenant.count}"
puts "   Secretarias:          #{Secretary.unscoped.count}"
puts "   Usuários:             #{User.unscoped.count}"
puts "   Produtores:           #{Producer.unscoped.count}"
puts "   Propriedades:         #{Property.unscoped.count}"
puts "   Maquinários:          #{Machine.unscoped.count}"
puts "   Prestadores:          #{ServiceProvider.unscoped.count}"
puts "   Ordens de Serviço:    #{ServiceOrder.unscoped.count}"
puts "   Endereços:            #{Address.count}"

puts "\n🔑 Credenciais de acesso (senha: Senha@123):"
Tenant.all.each do |t|
  puts "   #{t.subdomain.ljust(15)} → admin@#{t.subdomain}.local"
end

puts "\n💡 Para acessar, use o subdomínio ou header X-Tenant:"
puts "   http://agronna.localhost:3000"
puts "   http://fazendaboa.localhost:3000"
puts "   http://ruraltech.localhost:3000"
puts "\n"

# Reabilitar auditing após o seed
Audited.auditing_enabled = true
