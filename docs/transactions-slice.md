# Transações

Este slice transforma `transactions` em uma capacidade vertical completa para
receitas, despesas e transferências, mantendo regras financeiras fora da UI e
detalhes de SQLite fora dos casos de uso.

## Limites do módulo

- `domain`: `FinancialTransaction` e `TransactionRepository`;
- `application`: criação, listagem, cancelamento e catálogo abstrato de contas;
- `data`: adaptadores em memória e Drift;
- `presentation`: controller Riverpod, listagem responsiva, filtros, detalhes e
  formulário dedicado;
- `app/data`: único adaptador que traduz `accounts` para o catálogo estreito que
  `transactions` consome. Nenhuma feature importa outra diretamente.

O banco Drift é compartilhado em `shared/data` porque contas e transações
precisam da mesma conexão e de integridade referencial. Cada feature continua
dona do seu mapeamento e do seu contrato de repositório. O schema 2 adiciona
`transaction_entries` por migração, preservando instalações com o schema 1.

## Regras entregues

- Valores de transação são magnitudes positivas em unidades menores inteiras.
- O sinal e as pernas contábeis vêm exclusivamente de `core/ledger`.
- Receita e despesa comuns usam uma conta; compra no cartão usa o cartão.
- Transferência exige duas contas comuns, distintas e na mesma moeda.
- Conta arquivada não aceita novo lançamento, mas continua nomeada no histórico.
- Cancelar altera o estado para `Cancelado`; o registro não é apagado.
- Estados previsto, pendente, compensado, conciliado e cancelado mantêm o
  vocabulário fixo pt-BR.

## Experiência

No mobile, lançamentos são agrupados por dia e os detalhes abrem em bottom
sheet. No desktop, a lista densa abre um painel contextual de 360 px. Busca por
descrição/categoria, filtros por natureza, modo privacidade, estados de loading,
erro e vazio, e texto ampliado fazem parte do fluxo.

O formulário registra descrição, valor, conta, categoria, data, estado e nota.
Ao escolher um cartão para uma despesa, o domínio recebe `cardPurchase`, sem
expor essa distinção contábil como complexidade extra para a pessoa usuária.

## Integração concluída

O slice de visão geral agora consome contas e lançamentos por um contrato de
leitura próprio e calcula saldos confirmado e projetado com as regras canônicas
de `core/ledger`. Os detalhes estão em `docs/overview-balances-slice.md`.
