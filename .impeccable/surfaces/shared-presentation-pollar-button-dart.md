---
version: 1
slug: "shared-presentation-pollar-button-dart"
primary_target: "apps/pollar_app/lib/shared/presentation/pollar_button.dart"
related_targets:
  - "apps/pollar_app/lib/shared/presentation/pollar_focus_outline.dart"
  - "apps/pollar_app/lib/shared/presentation/pollar_states.dart"
  - "apps/pollar_app/lib/shared/presentation/pollar_modal.dart"
---

Scope: Polimento/acessibilidade, fase 8. Mode: Operate; herda PRODUCT/DESIGN e identidade vigente.
Thesis: reconhecer, percorrer e ativar ações nativas com nome, estado e foco inequívocos.
Form: acabamento dos controles existentes; sem mudança de fontes, paleta, tokens ou geometria.
First viewport: foco de teclado em `info`, traço 2px e vão 2px externos; contraste ≥3:1 sobre canvas/background/financialSurface em ambos os temas.
Focus ownership: FocusableActionDetector sem semântica própria, FocusNode com skipTraversal e CustomPaint; descendente nativo mantém foco/ativação, sem nova parada Tab.
Semantics: exclui só conteúdo visual; TextButton conserva papel, tap, foco e estado. Busy anuncia “rótulo, carregando” em live region e desabilitado não ativa.
States: primary/secondary/ghost/danger busy conservam cores ativas e texto AA ≥4,5:1; ghost desabilitado multiplica alpha existente, mantendo zero transparente.
Icon actions: selected null é ação; bool explícito expõe seleção nativa. Tooltip fornece nome; ícone desabilitado multiplica alpha por 0,55.
Feedback: PollarMotion.reduced troca spinners por ícone estático; sheet/erro expõem cabeçalhos e retry permite altura adaptável.
Evidence: duas rodadas visuais, reviewer fresco com disposition SHIP em cinco blocos e detector único encerrado sem achados materiais; capturas polish_*.
Boundary: fases visuais 1–5, 7 e 8 implementadas; Inteligência (6) condicional fora do redesign. Resultados finais e limites: [redesign-progress](../../docs/redesign-progress.md); aceite físico de AT/FPS separado.
