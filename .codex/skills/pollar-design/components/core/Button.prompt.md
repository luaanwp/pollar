One-line: the standard Pollar action control — use `primary` for the one main action per region, `secondary` for alternatives, `ghost` for low-emphasis toolbar actions, `danger` for destructive ones.

```jsx
<Button iconLeft="plus">Nova transação</Button>
<Button variant="secondary" size="compact">Filtros</Button>
<Button variant="danger" iconLeft="trash-2">Excluir cartão</Button>
```

Heights 32/40/48. Destructive actions must be labeled — never an unlabeled trash icon as the final confirmation. `loading` shows a spinner and disables the control.
