One-line: desktop modal for a single focused decision; on mobile use `BottomSheet` instead.

```jsx
<Dialog tone="danger" title="Excluir o cartão Ouro?"
  description="As 47 transações vinculadas continuarão no histórico, mas a fatura em aberto de R$ 4.123,90 deixará de ser acompanhada."
  actions={<><Button variant="secondary">Cancelar</Button><Button variant="danger">Excluir cartão</Button></>} />
```

Name the object and explain the impact. Prefer undo over confirmation for reversible operations.
