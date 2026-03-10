# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Multitenancy: tenant padrão para desenvolvimento
tenant = Tenant.find_or_create_by!(subdomain: "app") do |t|
  t.name = "Agronna App"
end

# Administrador principal da conta (apenas em desenvolvimento)
if Rails.env.development?
  admin = User.unscoped.find_or_create_by!(email: "admin@agronna.local", tenant: tenant) do |u|
    u.name = "Administrador"
    u.password = "senha123"
    u.role = :admin
  end
  tenant.update_column(:owner_id, admin.id) if tenant.owner_id.blank?
end
