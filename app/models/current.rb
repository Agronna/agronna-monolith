# frozen_string_literal: true

# Armazena o tenant e o usuário atual da requisição (multitenancy + autenticação).
# tenant: definido pelo ApplicationController a partir de subdomínio ou header.
# user: definido pelo ApplicationController a partir da sessão após login.
class Current < ActiveSupport::CurrentAttributes
  attribute :tenant
  attribute :user
end
