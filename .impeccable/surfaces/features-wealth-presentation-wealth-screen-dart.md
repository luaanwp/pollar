---
version: 1
slug: "features-wealth-presentation-wealth-screen-dart"
primary_target: "apps/pollar_app/lib/features/wealth/presentation/wealth_screen.dart"
related_targets: ["apps/pollar_app/lib/features/wealth/presentation/wealth_forms.dart"]
---

Scope: WealthScreen and its goal, asset, and debt creation forms. Mode: Operate.

Audience and job: a person maintaining a Brazilian household ledger who needs to understand current net worth, see what composes it, and keep one financial goal actionable without confusing manually valued property with account balances.

Primary tasks: choose a currency; inspect net worth and its asset/debt composition; add and update goals, manual assets, and debts; pause or complete records without deleting their history.

Proof and content: confirmed account positions from the ledger, exact manually entered valuations and outstanding debt, deterministic goal progress, explicit last-updated dates, and recoverable lifecycle states.

Direction: goal dossier. The first viewport pairs a net-worth balance sheet with the priority goal as a concrete case file. Supporting registers of assets, debts, and other goals explain the headline. The memorable moment is tracing one exact net-worth figure from accounts through property and obligations while seeing the next goal gap.

Constraints: inherit Pollar's flat teal-and-neutral world, pt-BR copy, exact tabular figures, privacy masking, light/dark themes, 200% text reflow, Android 48dp targets, no market-price claims, and no cross-feature imports outside app composition.

Unresolved: market feeds, amortization schedules, collateral links, shared goals, and historical valuation charts remain future adapters or later slices.

## Fase 5 — composição implementada

O contrato das primeiras seis linhas preserva o dossiê de metas e o mundo já
fixado; não define nova seed, identidade ou token. Uma única faixa
`financialSurface` sólida destaca patrimônio líquido em `amountHero` de 34px,
com Ativos acompanhados e Obrigações acompanhadas em 16px. Envelope
`PollarCard`, catálogo de fundamentos e demais consumidores permanecem.

- O balanço precede ações e meta prioritária no compacto. No amplo, balanço e
  meta ficam lado a lado e as ações seguem o par. Abertura e composição usam
  duas colunas somente com 960px úteis (viewport local menos 48px) e texto até
  1,3×, sem `IntrinsicHeight`. Cabeçalho mostra Moeda apenas se houver várias.
- Meta prioritária, registros de ativos, dívidas e outras metas e gerenciamento
  são grupos planos `Semantics`, com espaço e divisores. `_WealthValueRow`
  empilha identidade/valor abaixo de 600px locais ou acima de 1,3×;
  gerenciamento faz reflow abaixo de 760px locais ou com texto ampliado.
  Botões da tela e de confirmação usam altura adaptável. Dinheiro quebra com
  largura limitada e reserva geometria em privacidade.
- O total misto não recebe “Confirmado”: o rodapé explica que contas usam saldo
  confirmado e bens/dívidas manuais usam a última avaliação informada.
- Privacidade substitui percentuais no registro de metas, inclusive concluídas,
  por “Progresso oculto”, e taxa anual da dívida por “taxa oculta”. Datas e
  estados operacionais permanecem legíveis; proporção e valores ficam ocultos.
- Patrimônio líquido opta por `PrivacyAmount.animateChanges`/
  `PollarRollingAmount`, entre estados reais anterior/atual, com fallbacks
  existentes para privacidade, quebra e movimento reduzido. Progresso da meta
  prioritária e celebração após gravação bem-sucedida permanecem; não se
  introduzem Rive, novo cálculo ou histórico de avaliações.

Moedas, criação/edição, pausa reversível, conclusão e liquidação confirmadas
conservam seus contratos financeiros. Capturas `wealth_*` em
`apps/pollar_app/test/goldens/` registram compacto/amplo, claro/escuro,
privacidade, vazio, conteúdo longo e texto ampliado. Evidência final de suíte,
análise, build e runtime fica em `docs/redesign-progress.md`.

A fase 5 fecha esta migração visual. O próximo foco do redesign é Mobile
(fase 7); Inteligência (fase 6) continua condicional e fora deste slice.
