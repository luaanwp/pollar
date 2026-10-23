# Redesign Pollar — execução por fases

Plano de referência: [`UI_UX_REDESIGN_POLLAR.md`](../UI_UX_REDESIGN_POLLAR.md),
preservado como fornecido pelo usuário. A auditoria citava `2177e4f`; esta
implementação parte de `a2ab61e`, após as correções e o aceite da V1 interna.
Login, proteção de identidade, banco, cálculos e sincronização não são revertidos.

## Fase 1 — foundations

Modo: **Operate**. Direção já definida pelo plano: carteira pessoal com leitura
editorial, Inter e teal Pollar, números exatos, foco visível e migração explícita.
Esta fase implementa os papéis de componentes descritos no plano, preservando
a identidade Pollar. Não copia composições, marcas ou números das referências.

Implementação:

- `PollarCardVariant.outlined` conserva o padrão. `flat` remove a borda em
  agrupamento informativo; `financial` usa a superfície focal sólida. Variantes
  interativas continuam com limite visível e foco informativo de 2px.
- `financialSurface` é um alias de `primarySoft`, sem acrescentar hex à paleta.
  Texto primário, secundário e cores financeiras têm contraste AA testado nessa
  superfície, nos dois temas. Não usar texto atenuado sobre a superfície focal.
- `balanceHero` e `balanceHeroCompact` oferecem 40/34px por largura disponível
  do componente (limiar de 600px). `amountHero` legado permanece intacto até
  migração explícita das telas. Valores não encolhem nem animam seus dígitos.
- `PrivacyAmount.reserveLayout` é optativo e reserva as métricas visíveis e
  mascaradas. Corrige a mudança de altura reproduzida em 320px/130%; o valor
  oculto é apenas medido, não pintado nem exposto na árvore acessível.
  A moeda cede a linha antes de fragmentar o número; grupos só continuam em
  outra linha se o próprio corpo numérico não couber no tamanho de fonte pedido.
- A aba **Fundamentos** do catálogo tem exemplos declaradamente demonstrativos,
  sem criar contas/transações. `tool/design_catalog.dart` abre esse catálogo
  isolado, sem inicializar autenticação, perfil ou SQLite.
- Gradiente focal continua **condicional** e não foi implementado. Esta fase
  adota o fallback sólido previsto no plano; gradientes futuros exigem tokens
  derivados e auditoria de contraste antes de uso.

### Verificação

O aplicativo nativo existente foi aberto e inspecionado: duplicação de títulos
e foco visível por Tab observados. A árvore UIA do Flutter não expõe todos os
controles e capturas podem ficar ocluídas por outras janelas; nenhum envio ou
cadastro foi acionado. A prévia inicial foi encerrada normalmente e substituída
pelo catálogo isolado para não depender do perfil financeiro do usuário.

Os testes cobrem os dois temas, 320/390/1440px e escalas 1/1,3/2, além de foco,
ativação por Enter, legado contornado, contraste e privacidade acessível. Os
goldens do catálogo anterior mudam intencionalmente pela inclusão da quarta
aba; as telas de produto ainda não recebem a nova composição.

Resultado final em 2026-10-23: **300 testes passaram**, análise estática sem
problemas e catálogo isolado compilado/reiniciado no Windows. Os goldens são
renders Flutter, não capturas de um Android físico. Teclado e leitor de tela
do catálogo atualizado não foram declarados validados interativamente.

Revisão independente Impeccable: **PASS — phase 1 foundations**.

| Achado da revisão | Veredito final |
| --- | --- |
| Fragmentação numérica prematura em 320px/130% | Resolvido |
| Continuação em largura extrema e geometria da privacidade | Resolvido |
| Alinhamento de DESIGN.md, especificação e guia local | Resolvido |

Não restam achados materiais dessa revisão. O detector direcionado aos três
arquivos de card/catálogo retornou lista vazia; ele não substitui a análise
Flutter nem a revisão dos ajustes posteriores de privacidade.
O documenter preservou a composição atual das telas e registrou somente os
papéis implementados, sem gerar sidecar para esta atualização delimitada.

Execução isolada, a partir de `apps/pollar_app`:

```powershell
flutter run -d windows -t tool/design_catalog.dart
```

O comando é apenas para desenvolvimento. Não substitui o executável distribuído
nem cria um novo APK/ZIP da V1. O próximo pacote de produto será gerado após
migração e validação das telas.

## Fase 2 — shell e navegação

Implementação em 2026-10-23:

- Rail de 256/72px com recolhimento manual a partir de 1024px, preferência
  durante a sessão e preservação de branch, pilha de detalhes e rascunhos.
- Tablet mantém 72px; celular mantém os cinco destinos rotulados. Marca e
  destinos rolam em janelas baixas, sem reduzir os alvos para caber.
- Barra superior usa contexto secundário; tema, privacidade e Ctrl/Cmd+P
  permanecem globais. Transações compacta preserva seu único título de página
  e sua altura acompanha a escala do texto.
- Mais organiza Relatórios/Patrimônio em “Entenda seus dados” e os controles
  em “Seu aplicativo”, com linhas, divisores e foco visível de 2px.
- Mapa de rotas, autenticação, dados, cálculos e sincronização preservados.

Testes de widget exercitam rascunho, navegação entre branches, pilha de detalhe,
recolhimento, redimensionamento 390/800/1200px, teclado, privacidade, cinco
destinos de Mais, rolagem em janela de 320px de altura, alvos Android de 48px e
área segura inferior simulada. Cinco novos goldens de Mais cobrem claro/escuro,
320/390/800/1440px e texto de 2×. As referências das telas com shell são
atualizadas apenas por mudanças na navegação/barra superior.

Detector de layout antes/depois: lista vazia; não substitui a análise Flutter.
Resultado final: **315 testes passaram**, análise estática sem problemas e
revisão independente **PASS**, sem achados materiais nos arquivos e quatro
renders inspecionados. Os testes de pilha/rascunho usam páginas substitutas
para isolar o shell; não ampliam o aceite dos fluxos de autenticação/sync.
Os renders e a área segura são simulados: não há novo aceite físico Android,
iOS, leitor de tela ou pacote APK/ZIP nesta fase.

## Sequência restante

3. Visão geral: saldo antes da ação no mobile e hierarquia editorial; não
   alterar serviço, data source ou regras financeiras.
4. Contas, cartões, transações e planejamento: densidade, agrupamentos e reflow,
   mantendo todas as operações.
5. Análises/patrimônio: perguntas, critérios, valores e alternativas textuais.
6. Inteligência: fase condicional de produto, **não incluída** no redesign
   visual sem definição de dados e regras.
7. Refinamento mobile, complementando a validação feita em cada fase.
8. Polimento e acessibilidade transversal.

Esta fase não declara o redesign completo nem transforma as pendências de
aceite da V1 em resultados aprovados.
