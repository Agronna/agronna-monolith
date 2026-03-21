# Agendamento - Regras de Negócio

## Visão Geral

O **Agendamento** permite definir data/hora e alocar **maquinário** e **equipe** para a prestação de serviço, **após** o pagamento e a aprovação do comprovante da Ordem de Serviço. Um calendário integrado permite visualizar todos os agendamentos e filtrar por disponibilidade de maquinário e equipe.

---

## Fluxo

1. Ordem de Serviço criada (status Pendente ou Agendada).
2. Produtor paga e entrega comprovante → cadastro e **aprovação** do comprovante.
3. **Agendamento** é criado com maquinário e equipe alocados (os campos **início** e **término** do agendamento ficam em branco no cadastro; não são editáveis no formulário).
4. Na tela do agendamento, **Iniciar ordem de serviço** e **Finalizar ordem de serviço** registram `scheduled_at` e `scheduled_end_at` com o momento do clique (e o mesmo para `started_at` / `completed_at` na OS).

---

## Regra: Agendamento só após pagamento aprovado

- Apenas **Ordens de Serviço que possuem ao menos um comprovante de pagamento aprovado** podem receber agendamento.
- No formulário de novo agendamento, o select de OS lista somente essas OS (com status Pendente ou Agendada).
- Validação no model `Schedule`: `service_order_must_have_approved_receipt`.

---
## Regra: Sincronização com a Ordem de Serviço

Para manter consistência entre a Ordem de Serviço (OS) e o Agendamento (Schedule):

- **Maquinário sincronizado (OS -> Agendamento)**: ao criar ou atualizar um `Schedule`, o maquinário do agendamento é sempre sobrescrito para ser igual ao maquinário da OS (`service_order.machines`).
- **Horários do agendamento**: `scheduled_at` e `scheduled_end_at` **não** vêm do formulário de criação/edição; são definidos pelos botões **Iniciar** / **Finalizar** na tela do agendamento (momento do clique). Não há sincronização automática de data da OS para o agendamento ao editar a OS.

---

## Estrutura de Dados

### Schedule (agendamentos)

| Campo            | Tipo     | Obrigatório | Descrição                          |
|-----------------|----------|-------------|------------------------------------|
| scheduled_at    | DateTime | Não         | Início da execução (preenchido ao **Iniciar OS** na tela do agendamento) |
| scheduled_end_at| DateTime | Não         | Término (preenchido ao **Finalizar OS** na tela do agendamento)           |
| status          | Enum     | Sim         | Agendado, Confirmado, Em andamento, Concluído, Cancelado |
| observations    | Text     | Não         | Observações                        |
| tenant_id        | -        | Sim         | Organização                        |
| secretary_id    | -        | Sim         | Secretaria                         |
| service_order_id| -        | Sim         | Ordem de Serviço vinculada         |

### ScheduleMachine (maquinário alocado)

- `schedule_id`, `machine_id`
- Opcional: `hours_planned`, `notes`

### ScheduleAssignment (equipe alocada)

- `schedule_id`, `user_id`
- Opcional: `role`, `notes`

---

## Status do Agendamento

| Status         | Código       | Uso |
|----------------|--------------|-----|
| Agendado       | `scheduled`  | Criado, aguardando confirmação/execução |
| Confirmado     | `confirmed`  | Confirmado para o horário |
| Em andamento   | `in_progress`| Serviço em execução |
| Concluído      | `completed`  | Prestação realizada |
| Cancelado      | `cancelled`  | Agendamento cancelado |

---

## Calendário Integrado

- **Rota:** `/agendamentos/calendario`
- **Data/hora no calendário:** o dia e o horário exibidos usam **`COALESCE(service_orders.scheduled_at, schedules.scheduled_at)`** (prioriza data na OS, senão no agendamento). Só entram no calendário e no JSON de eventos registros com esse início efetivo definido. O **fim** do evento no calendário mantém a **duração** do agendamento (`scheduled_end_at` ou 1 hora), ancorada nesse início efetivo.
- **Visualização:** Grade mensal com todos os agendamentos (status Agendado, Confirmado, Em andamento) no período.
- **Filtros:**
  - **Por maquinário:** exibe apenas agendamentos que utilizam o maquinário selecionado → visualização da **disponibilidade** daquele equipamento (quando está ocupado).
  - **Por equipe:** exibe apenas agendamentos em que o usuário está alocado → visualização da **disponibilidade** daquele membro.
- Navegação: mês anterior / mês seguinte.
- Cada evento no calendário exibe hora, código da OS e, quando houver, nome do primeiro maquinário; ao clicar, abre a tela do agendamento.

---

## API de Eventos (JSON)

- **GET** `/agendamentos/events?start=...&end=...&machine_id=...&user_id=...`
- Retorna eventos no formato esperado por bibliotecas de calendário (FullCalendar, etc.):
  - `id`, `title`, `start`, `end`, `url`, `backgroundColor`, `extendedProps` (code, status, machines, users).

---

## Rotas

| Método | Rota | Ação |
|--------|------|------|
| GET    | `/agendamentos` | Lista de agendamentos |
| GET    | `/agendamentos/calendario` | Calendário mensal |
| GET    | `/agendamentos/events` | Eventos em JSON |
| GET    | `/agendamentos/novo` | Formulário de criação |
| POST   | `/agendamentos` | Criar |
| GET    | `/agendamentos/:id` | Visualizar |
| GET    | `/agendamentos/:id/editar` | Formulário de edição |
| PATCH  | `/agendamentos/:id` | Atualizar |
| DELETE | `/agendamentos/:id` | Excluir |

**Query params em Novo:** `service_order_id` (pré-seleciona a OS), `return_to=service_order` (redireciona de volta para a OS após salvar).

---

## Onde criar agendamento

- Menu **Agendamentos** → **Novo Agendamento**.
- Na tela da **Ordem de Serviço**, quando houver **Pagamento verificado** (comprovante aprovado), botão **"Agendar prestação"**.

---

## Bloqueio de edição após início

Quando **`scheduled_at`** do agendamento está preenchido (após **Iniciar ordem de serviço**), o registro **não pode mais ser editado** pelo formulário (maquinário, equipe, observações, etc.). Isso vale para todos os perfis, inclusive administradores. A finalização da OS (`scheduled_end_at`, status) continua sendo feita pelo botão **Finalizar ordem de serviço**, que não passa pelo formulário de edição.

---

## Iniciar e finalizar a Ordem de Serviço pelo agendamento

Na tela de detalhes do agendamento (`/agendamentos/:id`), usuários com permissão de atualizar a OS podem:

- **Iniciar ordem de serviço** (`PATCH /agendamentos/:id/iniciar-os`): chama `start!` na OS vinculada, desde que exista comprovante aprovado e a OS esteja Pendente ou Agendada. O **`started_at`** da OS e o **`scheduled_at`** do agendamento passam a ser o **date/hora do clique** (`Time.current`). O **`scheduled_at`** da OS também é alinhado. O status do agendamento passa para **Em andamento** quando estava Agendado ou Confirmado.
- **Finalizar ordem de serviço** (`PATCH /agendamentos/:id/finalizar-os`): chama `complete!` na OS quando ela está **Em andamento**. O **`completed_at`** da OS e o **`scheduled_end_at`** do agendamento passam a ser o **momento do clique**. O agendamento é marcado como **Concluído**.

As mesmas ações na **lista de ordens de serviço** só atualizam `started_at` / `completed_at` da OS com **hora atual**, sem alterar os horários do agendamento.

---

## Permissões (CanCanCan)

| Perfil        | Permissões |
|---------------|------------|
| Admin / Owner | Gerenciamento completo |
| Sub-admin     | Ler, criar, editar |
| Usuário       | Apenas leitura |

---

## Considerações Futuras

- [ ] Conflito de horário: validar sobreposição de agendamentos para o mesmo maquinário ou mesmo usuário.
- [ ] Notificações (e-mail/push) ao criar ou alterar agendamento.
- [ ] Vista semanal no calendário.
- [ ] Integração com calendário externo (iCal/Google).
