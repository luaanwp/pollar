One-line: the desktop transaction/statement table — sortable headers, row selection, sticky header, right-aligned amount column.

```jsx
<DataTable
  columns={[{key:'date',label:'Data',width:'110px'},{key:'title',label:'Descrição'},
            {key:'amount',label:'Valor',width:'140px',align:'right',render:r=><MoneyText minor={r.minor}/>}]}
  rows={rows} selectable selectedIds={sel} onSort={setSortKey} onRowClick={openPanel} />
```

On mobile, do not horizontally scroll this — switch to `TransactionTile` list items instead.
