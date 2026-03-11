# frozen_string_literal: true

# Inclua em models que pertencem a uma secretaria (e ao tenant).
# O model deve ter as colunas tenant_id e secretary_id.
# Garante escopo por tenant e associação com a secretaria.
#
# Uso:
#   class SecretaryEmployee < ApplicationRecord
#     include BelongsToTenant
#     include BelongsToSecretary
#   end
#
# Migration:
#   add_reference :secretary_employees, :tenant, null: false, foreign_key: true, index: true
#   add_reference :secretary_employees, :secretary, null: false, foreign_key: true, index: true
module BelongsToSecretary
  extend ActiveSupport::Concern

  included do
    belongs_to :secretary
    validates :secretary_id, presence: true
    # tenant_id já é tratado por BelongsToTenant quando usado junto
  end
end
