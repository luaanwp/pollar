# Slice de cartões, faturas e parcelamentos

Este slice transforma os termos já pertencentes às contas de cartão em ciclos financeiros operáveis, sem mover regras de cartões para a feature de contas.

## Limites modulares

- `features/transactions` persiste compras, pagamentos e metadados de parcelamento.
- `features/statements` deriva ciclos, totais, estados e compromissos futuros por contratos neutros.
- `app/data/card_statement_data_source.dart` é o único adaptador que conhece simultaneamente os repositórios de contas e transações.
- Drift armazena fatos financeiros; totais e estados de fatura continuam derivados.

## Regras entregues

- Uma compra parcelada gera lançamentos mensais ligados por `installmentGroupId`.
- A divisão conserva todos os centavos; eventuais restos ficam nas primeiras parcelas.
- Datas mensais preservam o dia quando possível e são limitadas ao último dia de meses curtos e anos bissextos.
- Cada compra pertence ao primeiro fechamento no mesmo dia ou depois da compra.
- O vencimento usa o mesmo mês somente quando ocorre depois do fechamento; caso contrário, usa o mês seguinte.
- Faturas distinguem Aberta, Fechada, Parcialmente paga, Paga e Vencida.
- Pagamentos integrais, parciais ou múltiplos são transferências da conta escolhida para o passivo do cartão e nunca uma nova despesa.
- Totais, pagamentos, saldo em aberto, limite disponível, compras e parcelas futuras usam a moeda do cartão.

## Persistência

O schema local passa para a versão 3, adicionando metadados opcionais de parcelamento, total original da compra e vínculo do pagamento à fatura. A migração preserva contas e transações existentes.

## Escopo posterior

Estornos, chargebacks, juros, tarifas, saque, antecipação, pagamento mínimo configurável, histórico/troca manual de ciclos e exportação permanecem extensões futuras dos contratos atuais.

O slice seguinte, planejamento recorrente, foi concluído em
`docs/planning-recurring-slice.md`.
