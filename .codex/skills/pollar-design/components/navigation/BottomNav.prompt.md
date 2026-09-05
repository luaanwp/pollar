One-line: the mobile shell's bottom navigation with an optional prominent quick-add button.

```jsx
<BottomNav activeId="home" onSelect={setTab} quickAdd="Nova transação" onQuickAdd={openSheet} items={[
  {id:'home',label:'Início',icon:'house'},{id:'tx',label:'Transações',icon:'list'},
  {id:'cards',label:'Cartões',icon:'credit-card'},{id:'more',label:'Mais',icon:'ellipsis'}]} />
```

Never more than five destinations, and the quick-add action must not obscure them.
