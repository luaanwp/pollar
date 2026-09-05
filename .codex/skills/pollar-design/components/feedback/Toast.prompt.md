One-line: transient confirmation of a low-risk success, optionally carrying an undo action.

```jsx
<Toast message="Transação excluída." actionLabel="Desfazer" onAction={undo} />
```

Only for low-risk confirmations. Anything the user must act on belongs in a `Banner`. Requires the `fin-toast-in` keyframes (see `guidelines/motion.card.html`) or it renders without animation.
