# Ordem de Serviço - Regras de Negócio

## Visão Geral

A Ordem de Serviço (OS) é o documento que formaliza a solicitação e execução de serviços no sistema Agronna. Ela permite rastrear desde a solicitação até a conclusão de trabalhos realizados em propriedades rurais.

---

## Estrutura de Dados

### Campos Principais

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| `code` | String | Sim (auto) | Código único gerado automaticamente (ex: OS-2026-0001) |
| `title` | String | Sim | Título descritivo da ordem de serviço |
| `description` | Text | Não | Descrição detalhada do serviço a ser executado |
| `deadline` | Date | Sim | Prazo limite para execução do serviço |
| `scheduled_at` | DateTime | Não | Data/hora agendada para início |
| `started_at` | DateTime | Não | Data/hora em que o serviço foi iniciado |
| `completed_at` | DateTime | Não | Data/hora em que o serviço foi finalizado |
| `status` | Enum | Sim | Status atual da ordem (ver seção Status) |
| `priority` | Enum | Sim | Nível de prioridade (ver seção Prioridades) |
| `observations` | Text | Não | Observações internas e notas adicionais |

### Relacionamentos

| Relacionamento | Tipo | Obrigatório | Descrição |
|----------------|------|-------------|-----------|
| `tenant` | belongs_to | Sim | Organização (multitenancy) |
| `secretary` | belongs_to | Sim | Secretaria responsável pela OS |
| `property` | belongs_to | Não | Propriedade onde o serviço será executado |
| `producer` | belongs_to | Não | Produtor solicitante |
| `service_provider` | belongs_to | Não | Prestador de serviço externo (se houver) |
| `assigned_to` | belongs_to User | Não | Usuário responsável pela execução |
| `requested_by` | belongs_to User | Não | Usuário que criou a solicitação |
| `machines` | has_many through | Não | Equipamentos envolvidos no serviço |

---

## Status da Ordem de Serviço

### Fluxo de Status

```
┌──────────┐     ┌───────────┐     ┌─────────────┐     ┌───────────┐
│ Pendente │────▶│ Agendada  │────▶│ Em Andamento│────▶│ Finalizada│
└──────────┘     └───────────┘     └─────────────┘     └───────────┘
      │               │                   │
      │               │                   │
      ▼               ▼                   ▼
┌───────────────────────────────────────────┐
│              Cancelada                     │
└───────────────────────────────────────────┘
```

### Descrição dos Status

| Status | Código | Descrição |
|--------|--------|-----------|
| **Pendente** | `pending` | OS criada, aguardando agendamento ou início |
| **Agendada** | `scheduled` | OS com data/hora de execução definida |
| **Em Andamento** | `in_progress` | Serviço em execução |
| **Finalizada** | `completed` | Serviço concluído com sucesso |
| **Cancelada** | `cancelled` | OS cancelada (não será executada) |

### Regras de Transição

1. **Iniciar** (`start!`):
   - Permitido apenas se status for `pending` ou `scheduled`
   - Define `started_at` com a data/hora atual
   - Muda status para `in_progress`

2. **Finalizar** (`complete!`):
   - Permitido apenas se status for `in_progress`
   - Define `completed_at` com a data/hora atual
   - Muda status para `completed`

3. **Cancelar** (`cancel!`):
   - Permitido em qualquer status exceto `completed`
   - Muda status para `cancelled`

---

## Edição Restringida

Uma Ordem de Serviço (OS) **não pode ser editada** (ação `edit` e atualização `update`) se:

- Existe **pagamento confirmado** para a OS (`payment_receipt_approved?` / “Pagamento verificado”);
- A OS está **cancelada** (`status = cancelled`).

Observação: a ação de **cancelar** (`cancel!`) é bloqueada apenas quando a OS **já** está cancelada.

---

## Prioridades

| Prioridade | Código | Uso Recomendado |
|------------|--------|-----------------|
| **Baixa** | `low` | Serviços que podem aguardar, sem urgência |
| **Normal** | `normal` | Padrão para a maioria das OS |
| **Alta** | `high` | Serviços importantes com prazo apertado |
| **Urgente** | `urgent` | Emergências que requerem ação imediata |

---

## Geração do Código

O código da OS é gerado automaticamente no formato:

```
OS-{ANO}-{SEQUENCIAL}
```

**Exemplo:** `OS-2026-0042`

### Regras:
- O ano é baseado na data de criação
- O sequencial é único por tenant e reinicia a cada ano
- O código é gerado antes da validação no `create`
- Formato fixo com 4 dígitos para o sequencial (ex: 0001, 0042, 0123)

---

## Equipamentos (Máquinas)

Uma OS pode ter múltiplos equipamentos vinculados através da tabela `service_order_machines`.

### Campos do Vínculo

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `machine_id` | Integer | ID do equipamento |
| `hours_used` | Decimal | Horas de uso do equipamento (opcional) |
| `notes` | Text | Observações específicas do uso (opcional) |

### Regras:
- Um equipamento só pode ser vinculado uma vez por OS
- O registro de horas é opcional e pode ser preenchido após a execução
- Apenas equipamentos ativos do mesmo tenant podem ser vinculados

---

## Ordem Atrasada

Uma OS é considerada **atrasada** quando:
1. O `deadline` (prazo) é anterior à data atual
2. E o status **não** é `completed` nem `cancelled`

### Indicação Visual:
- Na listagem, ordens atrasadas são destacadas em vermelho
- O badge "Atrasada" é exibido junto à data

---

## Permissões (CanCanCan)

| Perfil | Permissões |
|--------|------------|
| **Admin / Owner** | Gerenciamento completo (CRUD + ações de status) |
| **Sub-admin** | Criar, visualizar e editar (sem excluir) |
| **Usuário comum** | Apenas visualização |

---

## Rotas

| Método | Rota | Ação |
|--------|------|------|
| GET | `/ordens-servico` | Listar todas as OS |
| GET | `/ordens-servico/nova` | Formulário de criação |
| POST | `/ordens-servico` | Criar nova OS |
| GET | `/ordens-servico/:id` | Visualizar detalhes |
| GET | `/ordens-servico/:id/editar` | Formulário de edição |
| PATCH | `/ordens-servico/:id` | Atualizar OS |
| DELETE | `/ordens-servico/:id` | Excluir OS |
| PATCH | `/ordens-servico/:id/iniciar` | Iniciar execução |
| PATCH | `/ordens-servico/:id/finalizar` | Finalizar serviço |
| PATCH | `/ordens-servico/:id/cancelar` | Cancelar OS |

---

## Filtros Disponíveis (Ransack)

- **Código** (`code_cont`): Busca parcial no código
- **Título** (`title_cont`): Busca parcial no título
- **Status** (`status_eq`): Filtro por status exato
- **Prioridade** (`priority_eq`): Filtro por prioridade exata
- **Prazo até** (`deadline_lteq`): OS com prazo até a data informada

---

## Scopes Úteis

```ruby
ServiceOrder.overdue        # OS atrasadas
ServiceOrder.due_today      # OS com prazo para hoje
ServiceOrder.due_this_week  # OS com prazo nesta semana
```

---

## Exemplo de Uso

### Criar uma nova OS

```ruby
service_order = ServiceOrder.create!(
  tenant: Current.tenant,
  secretary: secretary,
  title: "Manutenção preventiva do trator",
  description: "Troca de óleo e filtros",
  deadline: Date.current + 7.days,
  priority: :normal,
  assigned_to: user,
  requested_by: current_user
)

# Vincular equipamentos
service_order.machines << Machine.find(1)
service_order.machines << Machine.find(2)
```

### Fluxo de Execução

```ruby
# Iniciar o serviço
service_order.start!
# => status: in_progress, started_at: Time.current

# Finalizar o serviço
service_order.complete!
# => status: completed, completed_at: Time.current
```

---

## Considerações Futuras

- [ ] Anexar arquivos/fotos à OS
- [ ] Notificações por e-mail ao mudar status
- [ ] Relatórios de produtividade por equipamento
- [ ] Histórico de alterações (audit trail já implementado)
- [ ] Integração com calendário para agendamentos
- [ ] Assinatura digital de conclusão
