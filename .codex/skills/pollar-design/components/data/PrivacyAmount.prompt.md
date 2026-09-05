One-line: wraps MoneyText with global privacy mode — masks the value as `R$ ••••••` without collapsing the layout.

```jsx
<PrivacyAmount minor={1234556} size="hero" hidden={privacyMode} />
```

Use it for every balance, net worth and statement total on dashboards. The toggle lives in the top bar / app bar and has a keyboard shortcut.
