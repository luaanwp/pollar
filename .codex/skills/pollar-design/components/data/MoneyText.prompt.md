One-line: the only sanctioned way to print money in Pollar — tabular numerals, locale formatting, true minus sign, polarity announced to screen readers.

```jsx
<MoneyText minor={1234556} size="hero" />
<MoneyText minor={-12345} />                       {/* neutral row: −R$ 123,45 */}
<MoneyText minor={45000} showSign tone="semantic" /> {/* summary: +R$ 450,00 in green */}
```

Use `tone="semantic"` only in summaries and comparisons. Transaction rows stay neutral with a minus sign to avoid alarm fatigue. Never below 12px.
