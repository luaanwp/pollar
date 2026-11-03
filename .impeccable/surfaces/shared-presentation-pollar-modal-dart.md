---
version: 1
slug: "shared-presentation-pollar-modal-dart"
primary_target: "apps/pollar_app/lib/shared/presentation/pollar_modal.dart"
related_targets:
  - "apps/pollar_app/lib/shared/presentation/pollar_text_field.dart"
  - "apps/pollar_app/lib/shared/presentation/pollar_form_controls.dart"
  - "apps/pollar_app/lib/app/routing/app_shell.dart"
  - "apps/pollar_app/lib/features/planning/presentation/planning_forms.dart"
  - "apps/pollar_app/lib/features/wealth/presentation/wealth_forms.dart"
  - "apps/pollar_app/lib/shared/presentation/pollar_motion.dart"
---

Scope: Mobile, fase 7. Mode: Operate; herda PRODUCT/DESIGN e tokens vigentes.
Thesis: ler, preencher e confirmar acima do teclado e das áreas do sistema, preservando o rascunho; contrato no comentário de `pollar_modal.dart`.
Form: extensão dos sheets/dialogs nativos, canvas sólido e tipografia Pollar; sem nova identidade.
Opening: sheet se largura <600px OU `size.height − viewInsets.bottom − padding.top <480px`; diálogo nativo no amplo.
First viewport: padding IME fora do scroll, bottom viewInsets consumido e SafeArea top false dentro do Material; conteúdo e ações rolam juntos.
Continuity: acima de 1,3×, rótulo externo completo, semântica visual excluída e campo nomeado com chave estável; preserva edição/seleção/foco e libera altura do Select.
Actions: seis botões de Planejamento/Patrimônio com altura adaptável; Done nos últimos numéricos de Planejamento encerra edição sem salvar implicitamente. Nomes/callbacks/dismissibilidade permanecem.
Shell/motion: proteção lateral compacta e inferior ampla, cinco destinos nativos; movimento reduzido remove animação sheet/dialog. Sem novos Rive, gráficos, regras financeiras, serviços, auth ou rotas.
Evidence: 18 testes funcionais novos, nove goldens mobile_* com IME simulado e três goldens 2× de Relatórios/Transações atualizados; duas rodadas visuais, reviewer fresco e detector encerrados sem achado material. Não implica aceite de hardware, AT ou FPS; resultados finais ficam em docs/redesign-progress.md. Próximo: fase 8; fase 6 permanece condicional.
