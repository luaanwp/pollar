One-line: the persistent status banner — offline, sync failure, conflict, or standing information.

```jsx
<Banner tone="warning" title="Você está offline" actions={<Button size="compact" variant="secondary">Tentar novamente</Button>}>
  As alterações ficam salvas no dispositivo e serão sincronizadas quando a conexão voltar.
</Banner>
```

Critical recovery instructions live here, never only in a disappearing toast. Replaces the spec's `SyncBanner` widget for sync/offline/conflict states.
