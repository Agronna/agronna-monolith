# Ícones SVG do sistema

Todos os ícones SVG usados na aplicação estão centralizados no helper **`IconHelper`** (`app/helpers/icon_helper.rb`). Eles podem ser reutilizados em qualquer view.

## Uso

```erb
<%= icon_svg(:nome_do_icone, class: "minha-classe", width: 24, height: 24) %>
```

### Opções

| Opção           | Padrão | Descrição                          |
|-----------------|--------|------------------------------------|
| `class`         | —      | Classe CSS do elemento `<svg>`     |
| `width`         | 24     | Largura em pixels                  |
| `height`        | 24     | Altura em pixels                   |
| `stroke_width`  | 1.5    | Espessura do traço                 |
| `aria_hidden`   | true   | Atributo aria-hidden               |

Qualquer outro parâmetro é repassado como atributo HTML do `<svg>` (ex.: `data: { ... }`).

## Ícones disponíveis

| Nome          | Uso no sistema                          |
|---------------|------------------------------------------|
| `dashboard`   | Menu Dashboard (home)                    |
| `calendar`    | Agendamento                              |
| `chart`       | Ativos e Passivos; formulário de **desempenho** do funcionário (`docs/FUNCIONARIOS_SECRETARIA.md`) |
| `receipt`     | Comprovantes de Pagamento; formulário de **feedbacks** do funcionário |
| `users`       | Usuários, grupos                         |
| `user`        | Produtores, perfil                       |
| `building`    | Prédio/instituição (KPI secretarias)     |
| `clipboard`   | Ordem de Serviço; formulário de **metas** do funcionário (`docs/FUNCIONARIOS_SECRETARIA.md`) |
| `wrench`      | Prestadores de Serviços                  |
| `tractor`     | Maquinários                              |
| `land`        | Propriedades                             |
| `office`      | Secretarias (menu Conta)                  |
| `close`       | Fechar menu (sidebar mobile)             |
| `menu`        | Abrir menu (navbar mobile)               |
| `arrow_right` | Seta para direita (links, navegação)     |

## Adicionar novo ícone

1. Abra `app/helpers/icon_helper.rb`.
2. Inclua uma nova entrada no hash `ICONS` com o nome (symbol) e o valor do atributo `d` do `<path>` (SVG outline 24x24).
3. Atualize a lista de ícones no comentário do módulo e neste arquivo.

Exemplo de entrada:

```ruby
novo_icone: "M12 3v18m9-9H3"
```

Os ícones seguem o estilo **Heroicons** (outline, 24x24, stroke).
