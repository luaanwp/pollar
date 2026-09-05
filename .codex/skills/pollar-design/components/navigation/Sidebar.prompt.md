One-line: the desktop shell's left navigation — selected item uses the primary-soft surface plus primary text, never color alone.

```jsx
<Sidebar activeId="dashboard" onSelect={setView} items={[
  {id:'dashboard',label:'Visão geral',icon:'layout-dashboard'},
  {section:'Contas'},
  {id:'cards',label:'Cartões',icon:'credit-card',badge:2}]} />
```

Collapsed (72px) items keep their tooltip via `title`. The brand mark is plain type — no logo file was supplied with the source spec.
