One-line: the top of the credit-card statement screen, in the mandated hierarchy (identity → totals → actions).

```jsx
<StatementSummary cardName="Cartão Ouro" brand="Visa" last4="4417" period="1–30 set 2026"
  status="Parcialmente paga" statusTone="warning" statusIcon="clock"
  totalMinor={-412390} paidMinor={-150000} dueDate="10 out 2026" limitMinor={800000}
  actions={<Button size="compact">Pagar fatura</Button>} />
```

Never present the statement payment as a second expense if purchases were already recorded.
