# Funcionários da secretaria (usuários)

Documentação das funcionalidades de **cadastro de funcionário** e **gestão de RH** ligadas ao modelo `User`: campos extras no usuário, ficha do funcionário com três abas (desempenho, metas, feedbacks), rotas e permissões.

---

## 1. Conceito

No sistema, cada **usuário** pertence a um **tenant** (conta) e, em geral, a uma **secretaria**. Esses usuários representam **funcionários** que acessam o sistema (administrador, sub-administrador ou usuário operacional).

Além dos dados já existentes (nome, e-mail, senha, secretaria, perfil), o cadastro passou a suportar **dados de vínculo trabalhista** e **históricos de RH** em tabelas dedicadas.

---

## 2. Novos campos no cadastro de usuário (`users`)

Estes campos aparecem no formulário de **novo usuário** e **editar usuário** e na **lista de usuários** (coluna Cargo + filtro).

| Campo (UI) | Coluna no banco | Tipo | Obrigatório | Descrição |
|------------|-----------------|------|-------------|-----------|
| **Cargo** | `job_title` | string | Não | Função ou papel exercido na secretaria (ex.: assistente administrativo). |
| **Data de contratação** | `hired_on` | date | Não | Data de admissão / início do vínculo. |

**Onde editar:** menu **Usuários** → **Editar** no usuário desejado (quem tiver permissão de atualizar aquele registro).

**Onde visualizar:** lista em `/usuarios` e na **ficha** do funcionário em `/usuarios/:id` (seção “Dados cadastrais”).

**Busca (Ransack):** na lista é possível filtrar por texto em **Cargo** (`job_title_cont`).

---

## 3. Ficha do funcionário (`/usuarios/:id`)

A **ficha** centraliza o perfil do colaborador:

- Resumo: secretaria, cargo, data de contratação, perfil de acesso.
- Três **abas** com histórico:
  1. **Desempenho**
  2. **Metas**
  3. **Feedbacks**

**Acesso:** na lista de usuários, botão **Ficha**; ou URL `GET /usuarios/:id`.

O layout segue o padrão do sistema (`container-fluid`, cards, breadcrumbs nos formulários aninhados).

---

## 4. Três módulos de RH (registros históricos)

Cada módulo é uma tabela própria, com `tenant_id` e vínculo ao `user_id` do funcionário. Alterações são auditadas (**Audited**).

### 4.1 Desempenho (`user_performance_records`)

Registros pontuais ou periódicos de avaliação.

| Campo | Descrição |
|-------|-----------|
| `recorded_on` | Data do registro (obrigatório). |
| `title` | Título opcional (ex.: avaliação trimestral). |
| `rating` | Nota opcional de **1 a 5**. |
| `notes` | Observações em texto livre. |

**Telas:** aba Desempenho na ficha; **Novo** / **Editar** em formulários com layout padrão (card + coluna lateral com ajuda e ações).

**Ícone no formulário:** `chart` (ver `docs/ICONES-SVG.md`).

---

### 4.2 Metas (`user_goals`)

Metas individuais com prazo e situação.

| Campo | Descrição |
|-------|-----------|
| `title` | Título da meta (obrigatório). |
| `description` | Detalhamento opcional. |
| `target_date` | Prazo desejado. |
| `status` | Situação (enum): `pending` (Pendente), `in_progress` (Em andamento), `achieved` (Alcançada), `cancelled` (Cancelada). |

**Ícone no formulário:** `clipboard`.

---

### 4.3 Feedbacks (`user_feedbacks`)

Registro de feedbacks sobre o funcionário.

| Campo | Descrição |
|-------|-----------|
| `feedback_on` | Data do feedback (obrigatório). |
| `kind` | Tipo: `general` (Geral), `positive` (Positivo), `improvement` (Melhoria). |
| `given_by_id` | Usuário que registrou o feedback (opcional; pode ser outra pessoa da conta). |
| `content` | Texto do feedback (obrigatório). |

Na criação, o sistema pode preencher o autor com o **usuário logado**; o campo pode ser alterado para outro usuário do mesmo tenant.

**Ícone no formulário:** `receipt`.

---

## 5. Rotas HTTP (paths em português)

Base: **`/usuarios`**

### Usuário e cadastro

| Método | Caminho | Ação |
|--------|---------|------|
| GET | `/usuarios` | Lista (filtros por nome, e-mail, perfil, secretaria, cargo). |
| GET | `/usuarios/cadastrar` | Novo usuário. |
| POST | `/usuarios` | Criar usuário. |
| GET | `/usuarios/:id` | Ficha do funcionário (abas). |
| GET | `/usuarios/:id/editar` | Editar usuário. |
| PATCH/PUT | `/usuarios/:id` | Atualizar usuário. |

### Desempenho (aninhado a `usuarios`)

| Método | Caminho | Ação |
|--------|---------|------|
| GET | `/usuarios/:user_id/desempenho/novo` | Formulário novo registro. |
| POST | `/usuarios/:user_id/desempenho` | Criar registro. |
| GET | `/usuarios/:user_id/desempenho/:id/editar` | Editar registro. |
| PATCH/PUT | `/usuarios/:user_id/desempenho/:id` | Atualizar. |
| DELETE | `/usuarios/:user_id/desempenho/:id` | Excluir. |

### Metas

| Método | Caminho | Ação |
|--------|---------|------|
| GET | `/usuarios/:user_id/metas/novo` | Nova meta. |
| POST | `/usuarios/:user_id/metas` | Criar meta. |
| GET | `/usuarios/:user_id/metas/:id/editar` | Editar meta. |
| PATCH/PUT | `/usuarios/:user_id/metas/:id` | Atualizar. |
| DELETE | `/usuarios/:user_id/metas/:id` | Excluir. |

### Feedbacks

| Método | Caminho | Ação |
|--------|---------|------|
| GET | `/usuarios/:user_id/feedbacks/novo` | Novo feedback. |
| POST | `/usuarios/:user_id/feedbacks` | Criar feedback. |
| GET | `/usuarios/:user_id/feedbacks/:id/editar` | Editar feedback. |
| PATCH/PUT | `/usuarios/:user_id/feedbacks/:id` | Atualizar. |
| DELETE | `/usuarios/:user_id/feedbacks/:id` | Excluir. |

**Controllers:** `Users::PerformanceRecordsController`, `Users::GoalsController`, `Users::FeedbacksController` (base: `Users::BaseController` com autorização por leitura do usuário pai e escrita condicionada a `authorize! :update, @user`).

---

## 6. Permissões (CanCanCan)

| Perfil | Lista / ficha de outros | Editar cadastro (cargo, contratação, etc.) | Criar/editar/excluir desempenho, metas e feedbacks |
|--------|-------------------------|--------------------------------------------|-----------------------------------------------------|
| **Administrador / dono da conta** | Sim | Sim, para qualquer usuário da conta | Sim, para qualquer usuário |
| **Sub-admin** | Sim (leitura da lista e ficha) | Apenas **próprio** usuário | Apenas registros do **próprio** `user_id` (não pode alterar RH de colega) |
| **Usuário** | Apenas o próprio perfil, conforme regras atuais | Apenas si mesmo | Não aplica gestão de terceiros |

Quem não pode dar `update` no usuário de destino **não** vê os botões de novo/editar/excluir na ficha; tentativas diretas de URL são bloqueadas pela autorização.

---

## 7. Internacionalização e formulários

- Textos de interface em **`config/locales/pt_BR.yml`** — chaves `users.*` e `helpers.submit` para os botões dos formulários.
- Os formulários de desempenho/metas/feedbacks usam o partial **`users/_hr_form_header`** (breadcrumb: Usuários → Ficha do funcionário → título da página).

---

## 8. Modelos e tabelas (referência técnica)

| Modelo | Tabela |
|--------|--------|
| `User` | `users` (+ `job_title`, `hired_on`) |
| `UserPerformanceRecord` | `user_performance_records` |
| `UserGoal` | `user_goals` |
| `UserFeedback` | `user_feedbacks` |

Todos os registros de RH incluem `tenant_id` e respeitam o escopo multitenancy (`BelongsToTenant`).

---

## 9. Auditoria

As tabelas `user_performance_records`, `user_goals` e `user_feedbacks` (e o próprio `User`) utilizam a gem **Audited** para histórico de alterações quando aplicável.

---

## 10. Documentação relacionada

- Ícones usados nos cabeçalhos dos formulários: **`docs/ICONES-SVG.md`**
- Regras gerais de permissões: `app/models/ability.rb`
