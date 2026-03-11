# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Multitenancy: tenant padrão para desenvolvimento
tenant = Tenant.find_or_create_by!(subdomain: "agronna") do |t|
  t.name = "Agronna App"
end

# Secretaria padrão (necessária para vincular usuários)
secretary = Secretary.unscoped.find_or_create_by!(tenant: tenant, cnpj: "00000000000191") do |s|
  s.name = "Secretaria Padrão"
  s.corporate_name = "Secretaria Padrão Agronna"
  s.email = "secretaria@agronna.local"
  s.prefecture_name = "Município Padrão"
  s.status = :active
end

# Administrador principal da conta (apenas em desenvolvimento)
if Rails.env.development?
  admin = User.unscoped.find_or_create_by!(email: "admin@agronna.local", tenant: tenant) do |u|
    u.name = "Administrador"
    u.password = "senha123"
    u.role = :admin
    u.secretary = secretary
  end
  admin.update_columns(secretary_id: secretary.id) if admin.secretary_id.blank?

  tenant.update_column(:owner_id, admin.id) if tenant.owner_id.blank?
end
