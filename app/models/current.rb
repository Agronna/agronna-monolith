# frozen_string_literal: true

# Armazena o tenant atual da requisição (multitenancy).
# Definido pelo middleware/ApplicationController a partir de subdomínio, header ou sessão.
class Current < ActiveSupport::CurrentAttributes
  attribute :tenant
end
