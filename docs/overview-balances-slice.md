# Visão geral e saldos derivados

Este slice substitui os valores demonstrativos da visão geral por um modelo de
leitura calculado a partir das contas e transações persistidas.

## Limites do módulo

- `overview/application` define o contrato `OverviewDataSource` e coordena o
  cálculo do snapshot;
- `overview/domain` contém somente os modelos derivados apresentados pelo
  dashboard;
- `overview/presentation` contém controller, mapeamentos visuais e widgets
  responsivos menores;
- `app/data/DashboardOverviewDataSource` é o ponto de composição autorizado a
  ler os repositórios de contas e transações. A feature `overview` não importa
  nenhuma das duas capacidades.

Um sinal compartilhado de revisão financeira não transporta dados nem regras.
Ele apenas invalida modelos de leitura depois de mutações; os repositórios
continuam sendo a fonte de verdade.

## Regras entregues

- saldos confirmado e projetado usam exclusivamente `computeAccountBalance` e
  os postings canônicos de cada transação;
- o saldo do dashboard soma contas patrimoniais ativas e apresenta cartões
  separadamente como dívida, evitando misturar caixa e passivo;
- moedas diferentes geram resumos separados e nunca são somadas;
- o resultado projetado do mês inclui receitas e despesas previstas, pendentes,
  compensadas ou conciliadas do período;
- transferências, pagamentos de fatura e transações canceladas não entram no
  resultado mensal;
- contas arquivadas ficam preservadas, mas não compõem os cartões ativos;
- lançamentos cancelados continuam no histórico recente com seu estado.

## Experiência

No desktop, a posição confirmada/projetada e o resultado mensal formam um
resumo assimétrico, seguido por posições de contas e transações recentes em
duas colunas. No mobile, a mesma ordem vira uma coluna rolável. Todos os valores
respeitam o modo privacidade sem mudar a estrutura. Loading, erro recuperável,
ausência de contas, ausência de transações e texto ampliado a 200% são cobertos.

## Próxima integração

O slice seguinte de cartões, faturas e parcelamentos foi concluído. A evolução
está documentada em `docs/cards-statements-installments-slice.md`.
