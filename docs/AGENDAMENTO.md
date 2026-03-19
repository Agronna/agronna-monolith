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
