One-line: the dashboard KPI card — level 1 of the dashboard hierarchy (balance, monthly result).

```jsx
<MetricCard title="Saldo total" helper="Todas as contas" minor={1873455}
  comparisonMinor={124300} comparisonLabel="vs. agosto" privacyHidden={priv} />
```

Amounts route through PrivacyAmount automatically. Add a `<TrendChart/>` as a child for the compact visualization.
