# Slice de planejamento recorrente

Este slice reúne a leitura mensal de orçamento, compromissos recorrentes,
assinaturas, calendário e lembretes sem transformar planos em fatos do
livro-caixa.

## Limites modulares

- `features/planning/domain` contém orçamentos, regras de recorrência e o
  snapshot mensal.
- `features/planning/application` calcula progresso, ocorrências e lembretes
  por contratos neutros.
- `features/planning/data` implementa a persistência substituível em Drift ou
  em memória.
- `app/data/planning_ledger_data_source.dart` é o único adaptador que traduz
  contas e transações para a linguagem de planejamento.
- A apresentação consome apenas o snapshot e casos de uso da própria feature.

## Regras entregues

- Um orçamento pertence a categoria, mês e moeda, com limite exato e limiar
  configurável entre 1% e 100%.
- Despesas e compras no cartão não canceladas compõem o gasto real da categoria.
- Receitas, transferências, pagamentos de fatura, outros meses e outras moedas
  nunca atravessam o cálculo.
- Não pode haver dois orçamentos ativos para a mesma categoria, mês e moeda.
- Compromissos podem ser entradas, pagamentos ou assinaturas com frequência
  semanal, mensal ou anual.
- Recorrências mensais e anuais limitam o dia ao fim de meses curtos e anos
  não bissextos; recorrências semanais preservam intervalos de sete dias.
- Calendário e lembretes são projeções reconstruíveis. Criar uma regra não gera
  uma transação automaticamente.
- Lembretes mostram quando a data entra na antecedência configurada e deixam
  explícito que vivem neste dispositivo.
- Orçamentos e compromissos podem ser pausados e retomados sem apagar sua
  configuração; somente itens ativos participam das projeções do mês.
- Formulários de criação permanecem abertos durante a persistência, bloqueiam
  o descarte enquanto salvam e preservam os campos quando o repositório falha.

## Persistência

O schema local passa para a versão 4 com tabelas próprias para orçamentos e
regras recorrentes. Migrações vindas das versões 1, 2 e 3 preservam contas e
transações e criam as novas tabelas vazias.

## Escopo posterior

Entrega por notificação do sistema operacional, confirmação/baixa de uma
ocorrência, exceções por competência, término de recorrência, reajustes,
rateio de orçamento, metas compartilhadas e automações ficam atrás dos
contratos atuais para evolução posterior.

O próximo slice recomendado é patrimônio e análise: metas, dívidas, ativos,
relatórios avançados, importação, exportação e backups.
