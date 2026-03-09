# Multitenancy com PostgreSQL

Documentação da estrutura de multitenancy implementada no projeto (abordagem **row-level**: um banco, tabela `tenants`, e `tenant_id` nas tabelas por tenant).

---

## O que foi feito

### 1. Tabela `tenants`

- **Migration:** `db/migrate/20260309232425_create_tenants.rb`
- **Tabela:** `tenants`
  - `name` (string, obrigatório)
  - `subdomain` (string, obrigatório, único)
  - `timestamps`
- Índice único em `subdomain`.

### 2. Model `Tenant`

- **Arquivo:** `app/models/tenant.rb`
- Validações:
  - `name` e `subdomain` obrigatórios
  - `subdomain` único (case insensitive)
  - Formato: letras, números e hífens (2–63 caracteres)
  - Subdomínios reservados: `www`, `admin`, `api`, `mail`, `ftp`, `app`
- Método de classe: `Tenant.find_by_subdomain(subdomain)`
- Normalização: subdomínio em minúsculas e sem espaços

### 3. Current tenant (`Current`)

- **Arquivo:** `app/models/current.rb`
- Usa `ActiveSupport::CurrentAttributes` para armazenar o tenant da requisição em `Current.tenant`
- Limpo automaticamente ao final de cada request

### 4. Concern `BelongsToTenant`

- **Arquivo:** `app/models/concerns/belongs_to_tenant.rb`
- Para models que pertencem a um tenant:
  - `belongs_to :tenant`
  - `default_scope { where(tenant: Current.tenant) }` quando `Current.tenant` está definido

### 5. Definição do tenant no request

- **Arquivo:** `app/controllers/application_controller.rb`
- `before_action :set_current_tenant`:
  - Resolve o tenant por **subdomínio** (`request.subdomain`) ou pelo header **`X-Tenant`**
  - Atribui o resultado a `Current.tenant`

### 6. Seeds

- **Arquivo:** `db/seeds.rb`
- Tenant de exemplo para desenvolvimento: subdomínio `app`, nome "Agronna App"

### 7. Tradução

- **Arquivo:** `config/locales/en.yml`
- Mensagem de validação para `subdomain` inválido

---

## Como usar

### Incluir tenant em um novo model

1. **Migration** – adicionar referência ao tenant:

   ```ruby
   add_reference :produtos, :tenant, null: false, foreign_key: true, index: true
   ```

2. **Model** – incluir o concern:

   ```ruby
   class Produto < ApplicationRecord
     include BelongsToTenant
   end
   ```

### Identificação do tenant na requisição

- **Subdomínio:** ex. `app.seudominio.com` → tenant com `subdomain: "app"`
- **Header:** enviar `X-Tenant: app` (útil para APIs ou quando não há subdomínio)

### Desenvolvimento local

- Configurar subdomínios no `/etc/hosts` se for testar por subdomínio
- Ou usar o header `X-Tenant: app` (tenant criado no seed)

---

## Arquivos criados/alterados

| Arquivo | Ação |
|---------|------|
| `db/migrate/20260309232425_create_tenants.rb` | Criado |
| `db/schema.rb` | Atualizado (tabela `tenants`) |
| `app/models/tenant.rb` | Criado |
| `app/models/current.rb` | Criado |
| `app/models/concerns/belongs_to_tenant.rb` | Criado |
| `app/controllers/application_controller.rb` | Alterado (`set_current_tenant`) |
| `db/seeds.rb` | Alterado (tenant exemplo) |
| `config/locales/en.yml` | Alterado (mensagem de validação) |
