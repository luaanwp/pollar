One-line: one budget line — category, spent-of-limit amounts, progress meter and a non-color warning cue past 85%/100%.

```jsx
<BudgetProgress category="Alimentação" icon="shopping-basket" spentMinor={-138050} limitMinor={160000} />
```

Tone escalates automatically: primary → warning (≥85%) → danger (≥100%), always paired with an icon and text percentage.
