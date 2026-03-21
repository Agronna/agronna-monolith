# Agendamento - Regras de Negócio

## Visão Geral

O **Agendamento** permite definir data/hora e alocar **maquinário** e **equipe** para a prestação de serviço, **após** o pagamento e a aprovação do comprovante da Ordem de Serviço. Um calendário integrado permite visualizar todos os agendamentos e filtrar por disponibilidade de maquinário e equipe.

---

## Fluxo

1. Ordem de Serviço criada (status Pendente ou Agendada).
2. Produtor paga e entrega comprovante → cadastro e **aprovação** do comprovante.
3. **Agendamento** é criado: data/hora de início (e opcionalmente fim), maquinário e equipe alocados.
4. No dia/hora agendados, a OS pode ser iniciada e executada.

---

## Regra: Agendamento só após pagamento aprovado

- Apenas **Ordens de Serviço que possuem ao menos um comprovante de pagamento aprovado** podem receber agendamento.
- No formulário de novo agendamento, o select de OS lista somente essas OS (com status Pendente ou Agendada).
- Validação no model `Schedule`: `service_order_must_have_approved_receipt`.

---
## Regra: Sincronização com a Ordem de Serviço

Para manter consistência entre a Ordem de Serviço (OS) e o Agendamento (Schedule):

- **Maquinário sincronizado (OS -> Agendamento)**: ao criar ou atualizar um `Schedule`, o maquinário do agendamento é sempre sobrescrito para ser igual ao maquinário da OS (`service_order.machines`).
- **Data sincronizada (OS -> Agendamento)**: quando `scheduled_at` (e `scheduled_end_at`, se existir) é alterado na OS, todos os `Schedule`s vinculados a ela têm a data/hora ajustada para refletir a OS.
- **Sem sincronização reversa**: alterar `scheduled_at` diretamente no `Schedule` **não** altera a OS.

---

## Estrutura de Dados

### Schedule (agendamentos)

| Campo            | Tipo     | Obrigatório | Descrição                          |
|-----------------|----------|-------------|------------------------------------|
| scheduled_at    | DateTime | Sim         | Data e hora de início              |
| scheduled_end_at| DateTime | Não         | Data e hora de término             |
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
- **Data/hora no calendário:** o dia e o horário exibidos usam **`service_order.scheduled_at`** (data de agendamento na Ordem de Serviço), quando preenchido; caso contrário, usa-se `schedule.scheduled_at`. O **fim** do evento no calendário mantém a **duração** definida no agendamento (`scheduled_end_at` ou 1 hora), ancorada nesse início efetivo — não é necessário campo extra na tabela.
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
