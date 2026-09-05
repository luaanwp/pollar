One-line: square icon-only control for toolbars, table row actions and app-bar utilities; `label` is mandatory and supplies the tooltip.

```jsx
<IconButton icon="eye-off" label="Modo privacidade" />
<IconButton icon="sliders-horizontal" label="Colunas" variant="outline" size="compact" />
```

On mobile use `size="prominent"` (48px) to satisfy the 44×44 minimum target. Never use an icon-only button to confirm a destructive action.
