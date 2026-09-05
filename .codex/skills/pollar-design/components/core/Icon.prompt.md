One-line: renders a Lucide rounded-outline glyph tinted with currentColor — the only sanctioned way to place an icon in Pollar UI.

```jsx
<Icon name="wallet" size={20} />
<Icon name="trash-2" size={16} color="var(--negative)" label="Excluir" />
```

Sizes: 16 (dense rows), 20 (default / desktop nav), 24 (mobile nav, section headers). Never use emoji as a product icon. Unlabeled icon controls must carry a tooltip — see `IconButton`.
