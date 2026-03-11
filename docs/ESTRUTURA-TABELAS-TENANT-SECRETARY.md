# Estrutura de tabelas com Tenant e Secretarias

Este documento descreve o padrão para criar novas tabelas no projeto que usam **multitenancy** (tenant) e, quando aplicável, **relacionamento com Secretarias**.

---

## Hierarquia

```
Tenant (conta)
├── Users (cada usuário pertence a uma secretaria)
│   └── user.secretary_id → Secretary
├── Secretaries (secretarias)
│   ├── users (usuários da secretaria)
│   └── [outras entidades, ex.: Funcionários, Agendamentos]
└── [outras entidades da conta, ex.: Produtores, Propriedades]
```

- **Tenant:** cada conta (subdomínio) tem seus próprios dados.
- **Secretaries:** pertencem a um tenant; cada conta tem suas secretarias.
- **Users:** pertencem a um tenant **e** a uma secretaria (`secretary_id`). Todo usuário é vinculado a uma secretaria.
- **Entidades “filhas” da secretaria:** têm `tenant_id` e `secretary_id` (ex.: funcionários da secretaria, ordens de serviço por secretaria).

---

## 1. Tabelas que pertencem só ao Tenant

Entidades que são da **conta** (tenant), sem vínculo direto com uma secretaria.

**Exemplos:** Secretaries, Produtores, Propriedades, Maquinários (quando forem da conta).

### Migration

```ruby
class CreateProdutores < ActiveRecord::Migration[8.1]
  def change
    create_table :produtores do |t|
      t.references :tenant, null: false, foreign_key: true, index: true
      t.string :nome, null: false
      # ... outros campos
      t.timestamps
    end

    # Se precisar de unicidade por tenant (ex.: documento)
    add_index :produtores, [ :tenant_id, :cpf ], unique: true
  end
end
```

### Model

```ruby
class Produtor < ApplicationRecord
  include BelongsToTenant

  validates :nome, presence: true
  # Unicidade sempre escopada ao tenant quando fizer sentido
  # validates :cpf, uniqueness: { scope: :tenant_id }
end
```

### Controller (criar registro)

Sempre atribuir o tenant na criação:

```ruby
def create
  @produtor = Produtor.new(produtor_params)
  @produtor.tenant = Current.tenant
  if @produtor.save
    # ...
  end
end
```

---

## 2. Tabelas que pertencem ao Tenant e à Secretary

Entidades que são **de uma secretaria** dentro da conta (ex.: funcionários da secretaria, agendamentos por secretaria).

Use **sempre** `tenant_id` e `secretary_id`:

- **tenant_id:** escopo por conta e uso do `BelongsToTenant` (e filtros por tenant).
- **secretary_id:** vínculo com a secretaria (e possíveis listagens por secretaria).

### Migration

```ruby
class CreateSecretaryEmployees < ActiveRecord::Migration[8.1]
  def change
    create_table :secretary_employees do |t|
      t.references :tenant, null: false, foreign_key: true, index: true
      t.references :secretary, null: false, foreign_key: true, index: true
      t.string :nome, null: false
      t.string :email, null: false
      # ...
      t.timestamps
    end

    add_index :secretary_employees, [ :tenant_id, :email ], unique: true
  end
end
```

### Model

Inclua **BelongsToTenant** e **BelongsToSecretary**:

```ruby
class SecretaryEmployee < ApplicationRecord
  include BelongsToTenant
  include BelongsToSecretary

  validates :nome, presence: true
  validates :email, presence: true, uniqueness: { scope: :tenant_id, case_sensitive: false }
end
```

### Controller (criar registro)

Definir tenant e secretaria (a secretaria já pertence ao tenant):

```ruby
def create
  @employee = SecretaryEmployee.new(secretary_employee_params)
  @employee.tenant = Current.tenant
  @employee.secretary_id = params[:secretary_id] # ou pelo formulário
  if @employee.save
    # ...
  end
end
```

Garanta que a secretaria escolhida seja do tenant atual (ex.: listar só `Secretary.all` ou filtrar por `Current.tenant`).

---

## 3. Resumo dos concerns

| Concern              | Uso                                      | Colunas na tabela   |
|----------------------|------------------------------------------|----------------------|
| `BelongsToTenant`    | Tudo que pertence à conta                 | `tenant_id`          |
| `BelongsToSecretary` | O que é “filho” de uma secretaria        | `tenant_id` + `secretary_id` |

- **Só tenant:** `BelongsToTenant` + `tenant_id`.
- **Tenant + Secretaria:** `BelongsToTenant` + `BelongsToSecretary` + `tenant_id` + `secretary_id`.

---

## 4. Secretarias no projeto

- A tabela **secretaries** tem `tenant_id` (cada conta tem suas secretarias).
- O model **Secretary** inclui `BelongsToTenant` e valida `tenant_id` presence.
- Unicidades (cnpj, email, name, etc.) são **por tenant** (`scope: :tenant_id`).
- No **SecretariesController**, ao criar: `@secretary.tenant = Current.tenant`.

**Se já existirem secretarias sem tenant:** rode um backfill (ex.: no console) atribuindo cada uma a um tenant; depois pode adicionar `null: false` em uma migration separada.

### Usuários vinculados à Secretaria

- **User** tem `tenant_id` e `secretary_id`; todo usuário pertence a uma secretaria (obrigatório para novos cadastros).
- No formulário de usuário (new/edit) o campo **Secretaria** é obrigatório; as opções vêm de `Secretary.all` (já escopado ao tenant).
- Validação garante que a secretaria escolhida seja do mesmo tenant do usuário.

---

## 5. Checklist para nova tabela

- [ ] Definir se a entidade é só da **conta** ou da **conta + secretaria**.
- [ ] Migration: adicionar `tenant_id` (e `secretary_id` se for caso de secretaria).
- [ ] Model: incluir `BelongsToTenant` (e `BelongsToSecretary` se tiver `secretary_id`).
- [ ] Unicidades sempre com `scope: :tenant_id` (e `scope: [ :tenant_id, :secretary_id ]` se fizer sentido).
- [ ] No create do controller: atribuir `record.tenant = Current.tenant` (e `record.secretary = ...` quando aplicável).
