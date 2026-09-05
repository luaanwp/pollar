One-line: the standard Pollar text field — label above, optional prefix/suffix, and default/hover/focus/filled/disabled/read-only/error/success states.

```jsx
<Input label="Descrição" placeholder="Ex. Mercado do bairro" />
<Input label="Vencimento" iconLeft="calendar" value="10 set 2026" readOnly />
<Input label="E-mail" error="Informe um e-mail válido, como nome@dominio.com" />
```

Never use a placeholder as the label. Errors say what happened *and* how to fix it. For money use `CurrencyInput`.
