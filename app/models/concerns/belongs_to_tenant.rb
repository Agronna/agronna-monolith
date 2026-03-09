# frozen_string_literal: true

# Inclua em models que pertencem a um tenant (multitenancy por linha).
# O model deve ter a coluna tenant_id e a tabela tenants deve existir.
#
# Uso:
#   class Product < ApplicationRecord
#     include BelongsToTenant
#   end
#
# Migrations para novas tabelas com tenant:
#   add_reference :products, :tenant, null: false, foreign_key: true, index: true
module BelongsToTenant
  extend ActiveSupport::Concern

  included do
    belongs_to :tenant
    default_scope { where(tenant: Current.tenant) if Current.tenant.present? }
  end
end
