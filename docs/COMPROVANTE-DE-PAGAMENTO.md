# Comprovante de Pagamento - Regras de Negócio

## Visão Geral

O **Comprovante de Pagamento** registra pagamentos realizados **fora do sistema** (ex.: em banco, em espécie). O produtor entrega o comprovante à secretaria, que faz o cadastro e anexa o arquivo (imagem ou PDF). Após **aprovação** do comprovante, a **Ordem de Serviço** vinculada pode ser **iniciada**.

---

## Fluxo Principal

1. **Ordem de Serviço** é criada (status Pendente ou Agendada).
2. **Pagamento** é realizado pelo produtor fora do sistema (banco, etc.).
3. **Produtor** entrega o comprovante (físico ou digital) à secretaria.
4. **Secretaria** cadastra o comprovante no sistema e **anexa** o arquivo (foto/PDF).
5. **Responsável** aprova ou rejeita o comprovante.
6. Com **ao menos um comprovante aprovado**, a OS pode ser **iniciada** (botão "Iniciar Ordem de Serviço").

---

## Cadastro Manual

- **Onde:** Menu "Comprovantes de Pagamento" ou na tela da Ordem de Serviço (botão "Anexar Comprovante").
- **Campos obrigatórios:** Ordem de Serviço, Data do pagamento, Valor, Secretaria, **Arquivo** (imagem ou PDF).
- **Campos opcionais:** Referência, Descrição, Produtor, Observações.
- **Origem:** `manual` (padrão).

O **arquivo** é obrigatório no cadastro manual. Formatos aceitos: **JPEG, PNG, GIF, WebP, PDF**. Tamanho máximo: **10 MB**.

---

## Importação de Comprovantes (Bancos)

- **Objetivo:** Permitir importação em lote a partir de arquivos gerados por bancos (ex.: OFX, CSV de extrato).
- **Origem:** `bank_import`.
- **Campos preenchidos na importação:** Podem vir `bank_name`, `bank_code`, `transaction_code`, `external_id`, além de `payment_date`, `amount`, `reference`.
- **Arquivo:** Na importação bancária o anexo pode ser opcional (os dados vêm do arquivo de importação); o sistema pode gerar ou permitir anexar depois.

A implementação da importação bancária fica em `app/services/payment_receipt_import/` (estrutura preparada para futura implementação de parsers por banco ou formato).

---

## Status do Comprovante

| Status      | Código   | Descrição |
|------------|----------|-----------|
| **Pendente** | `pending` | Cadastrado, aguardando aprovação ou rejeição |
| **Aprovado** | `approved` | Validado; a OS pode ser iniciada (se este for o primeiro aprovado) |
| **Rejeitado** | `rejected` | Não aceito; pode constar `rejection_reason` |

Apenas comprovantes **Pendentes** podem ser editados, aprovados ou rejeitados.

---

## Regra: Iniciar Ordem de Serviço

- **Condição:** A OS só pode ser **iniciada** se existir **ao menos um comprovante de pagamento com status Aprovado** vinculado a ela.
- **Mensagem:** Se o usuário tentar iniciar sem comprovante aprovado: *"É necessário ao menos um comprovante de pagamento aprovado para iniciar a ordem de serviço."*
- **Onde:** Botão "Iniciar Ordem de Serviço" na listagem ou na tela da OS.

---

## Relacionamentos

| Campo            | Tipo        | Obrigatório | Descrição |
|------------------|-------------|------------|-----------|
| `tenant`         | Tenant      | Sim        | Organização |
| `secretary`      | Secretary   | Sim        | Secretaria que recebeu o comprovante |
| `service_order`  | ServiceOrder| Sim        | Ordem de Serviço à qual o pagamento se refere |
| `producer`       | Producer    | Não        | Produtor que realizou o pagamento |
| `approved_by`    | User        | Não        | Usuário que aprovou/rejeitou |
| `file`           | Active Storage | Manual: Sim | Anexo (imagem ou PDF) |

---

## Ações Disponíveis

| Ação     | Quem        | Quando |
|----------|-------------|--------|
| Criar    | Admin, Sub-admin | Sempre (OS pendente ou agendada) |
| Editar   | Admin, Sub-admin | Apenas status Pendente |
| Aprovar  | Admin, Sub-admin | Apenas status Pendente |
| Rejeitar | Admin, Sub-admin | Apenas status Pendente |
| Excluir  | Conforme Ability | - |
| Visualizar | Todos (com permissão de leitura) | Sempre |

---

## Rotas

| Método | Rota | Ação |
|--------|------|------|
| GET    | `/comprovantes` | Listar |
| GET    | `/comprovantes/novo` | Formulário de criação |
| POST   | `/comprovantes` | Criar |
| GET    | `/comprovantes/:id` | Visualizar |
| GET    | `/comprovantes/:id/editar` | Formulário de edição |
| PATCH  | `/comprovantes/:id` | Atualizar |
| DELETE | `/comprovantes/:id` | Excluir |
| PATCH  | `/comprovantes/:id/aprovar` | Aprovar |
| PATCH  | `/comprovantes/:id/rejeitar` | Rejeitar |

**Query params em Novo:** `service_order_id` (pré-seleciona a OS), `return_to=service_order` (redireciona de volta para a OS após salvar).

---

## Filtros (Ransack)

- Data do pagamento (a partir de / até)
- Status (Pendente, Aprovado, Rejeitado)
- Referência (contém)

---

## Considerações Futuras

- [ ] Implementar parsers de importação bancária (OFX, CSV por banco).
- [ ] Permitir múltiplos anexos por comprovante.
- [ ] Motivo de rejeição obrigatório ao rejeitar.
- [ ] Notificação ao produtor quando o comprovante for aprovado ou rejeitado.
- [ ] Relatório de comprovantes por período/secretaria.
