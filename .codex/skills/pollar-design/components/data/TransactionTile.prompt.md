One-line: the canonical transaction row for mobile lists and desktop detail panels — keeps amounts in a consistent right-hand alignment column.

```jsx
<TransactionTile title="Mercado do bairro" category="Alimentação" account="Cartão Ouro"
  date="1 set 2026" minor={-23480} installment="3/12" status="Previsto" statusTone="neutral" statusIcon="clock" />
<TransactionTile title="Salário" kind="income" category="Renda" account="Conta corrente" date="1 set 2026" minor={920000} />
```

Expenses stay neutral with a minus sign; income uses the positive tone and a plus sign; transfers use the info color and a bidirectional arrow; card payments are informational, never a second expense.
