---
name: Pollar
description: Finanças pessoais com clareza calma, precisão e privacidade.
colors:
  primary: "#087F6B"
  primary-hover: "#066858"
  primary-soft: "#EAF8F4"
  canvas: "#FFFFFF"
  background: "#F7F9F8"
  surface-alt: "#F1F4F3"
  border: "#D8DEDC"
  border-strong: "#B9C3C0"
  text-primary: "#13201D"
  text-secondary: "#52615D"
  text-muted: "#66736F"
  success: "#0F7444"
  success-soft: "#E8F5EE"
  danger: "#C53B3B"
  danger-soft: "#FBECEC"
  warning: "#8B5707"
  warning-soft: "#FBF1E3"
  info: "#2667C9"
  info-soft: "#EAF0FB"
  dark-primary: "#5ED3B8"
  dark-primary-hover: "#80DEC9"
  dark-primary-soft: "#153B34"
  dark-canvas: "#121A18"
  dark-background: "#0C1211"
  dark-surface-alt: "#1A2522"
  dark-border: "#2D3B37"
  dark-border-strong: "#40514C"
  dark-text-primary: "#EEF4F2"
  dark-text-secondary: "#B5C3BF"
  dark-text-muted: "#8B9B96"
  dark-success: "#55CF91"
  dark-success-soft: "#12301F"
  dark-danger: "#FF8585"
  dark-danger-soft: "#3A1E1E"
  dark-warning: "#F3B85D"
  dark-warning-soft: "#38290F"
  dark-info: "#80AEFF"
  dark-info-soft: "#16233A"
typography:
  display:
    fontFamily: "Inter"
    fontSize: "32px"
    fontWeight: 700
    lineHeight: 1.2
    letterSpacing: "-0.02em"
  headline:
    fontFamily: "Inter"
    fontSize: "26px"
    fontWeight: 700
    lineHeight: 1.25
    letterSpacing: "-0.015em"
  title:
    fontFamily: "Inter"
    fontSize: "18px"
    fontWeight: 600
    lineHeight: 1.35
  body:
    fontFamily: "Inter"
    fontSize: "14px"
    fontWeight: 400
    lineHeight: 1.5
  label:
    fontFamily: "Inter"
    fontSize: "13px"
    fontWeight: 600
    lineHeight: 1.35
  amount:
    fontFamily: "Inter"
    fontSize: "16px"
    fontWeight: 600
    lineHeight: 1.3
    fontFeature: "tnum"
  balance-hero:
    fontFamily: "Inter"
    fontSize: "40px"
    fontWeight: 600
    lineHeight: 1.15
    fontFeature: "tnum"
  balance-hero-compact:
    fontFamily: "Inter"
    fontSize: "34px"
    fontWeight: 600
    lineHeight: 1.15
    fontFeature: "tnum"
  eyebrow:
    fontFamily: "Inter"
    fontSize: "11px"
    fontWeight: 600
    lineHeight: 1.3
    letterSpacing: "0.06em"
rounded:
  chip: "6px"
  control: "10px"
  card: "14px"
  badge: "999px"
spacing:
  x0: "0px"
  x1: "4px"
  x2: "8px"
  x3: "12px"
  x4: "16px"
  x5: "20px"
  x6: "24px"
  x8: "32px"
  x10: "40px"
  x12: "48px"
  x16: "64px"
  x20: "80px"
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.canvas}"
    typography: "{typography.label}"
    rounded: "{rounded.control}"
    padding: "0 16px"
    height: "40px"
  button-primary-hover:
    backgroundColor: "{colors.primary-hover}"
    textColor: "{colors.canvas}"
    rounded: "{rounded.control}"
  button-secondary:
    backgroundColor: "{colors.canvas}"
    textColor: "{colors.text-primary}"
    typography: "{typography.label}"
    rounded: "{rounded.control}"
    padding: "0 16px"
    height: "40px"
  button-ghost:
    backgroundColor: "transparent"
    textColor: "{colors.text-secondary}"
    typography: "{typography.label}"
    rounded: "{rounded.control}"
    padding: "0 16px"
    height: "40px"
  input:
    backgroundColor: "{colors.canvas}"
    textColor: "{colors.text-primary}"
    typography: "{typography.body}"
    rounded: "{rounded.control}"
    padding: "16px"
  card:
    backgroundColor: "{colors.canvas}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.card}"
    padding: "20px"
  card-flat:
    backgroundColor: "{colors.canvas}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.card}"
    padding: "20px"
  card-financial:
    backgroundColor: "{colors.primary-soft}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.card}"
    padding: "20px"
  badge-neutral:
    backgroundColor: "{colors.surface-alt}"
    textColor: "{colors.text-secondary}"
    rounded: "{rounded.badge}"
    padding: "0 10px"
    height: "24px"
---

# Design System: Pollar

## Overview

**Creative North Star: "O livro-caixa sereno"**

Pollar é uma interface de operação financeira privada, composta e precisa. A linguagem visual reduz ruído para que contas, cartões, saldos e estados possam ser reconhecidos e operados com segurança; configuração de uma conta permanece separada de seus lançamentos.

O sistema usa superfícies planas, neutros levemente esverdeados e uma única voz de marca em teal. Hierarquia vem de tipografia, espaçamento, alinhamento e bordas onde delimitam estrutura ou interação. Interações mantêm a familiaridade nativa do Flutter/Material 3, enquanto componentes Pollar fixam cor, forma e densidade.

**Key Characteristics:**

- Interface de operação calma, compacta e legível.
- Fundo e canvas como base, com uma superfície financeira focal opcional por viewport.
- Teal reservado a ação, seleção, identidade e à superfície focal nomeada.
- Agrupamentos por alinhamento e espaço; bordas de 1px para estrutura e interação.
- Valores financeiros exatos, algarismos tabulares e privacidade com reserva explícita de layout nos saldos que fazem reflow.
- Iconografia Lucide de contorno arredondado, sempre com rótulo acessível quando o controle não tem texto.

### Migração do redesign — fases implementadas

As fases implementadas de `UI_UX_REDESIGN_POLLAR.md` incluem fundamentos, navegação e Visão geral: variantes de cartão, superfície focal sólida, papéis de saldo, reserva de layout, rail recolhível e leitura financeira antes da ação no compacto. O catálogo demonstra os fundamentos; a Visão geral já os utiliza. As demais telas conservam suas regras operacionais até a migração explícita.

A fase 4A migra a listagem de Contas e cartões: linhas para contas/arquivadas, crédito com motion preservado, largura real e texto ampliado. A fase 4B migra Transações com controles adaptáveis, linhas completas e detalhe conforme a largura disponível. Planejamento continua na fase 4C.

| Regra anterior | Regra vigente e limite |
| --- | --- |
| Todo cartão tem borda de 1px | `outlined` continua padrão; `flat` e `financial` informativos omitem a borda. Qualquer cartão interativo conserva limite visível e foco informativo de 2px. |
| Teal restrito a pequenos sinais | Uma superfície financeira focal por viewport pode usar `financialSurface`, alias de `primarySoft`, sem nova cor. |
| Proibição incondicional de gradientes | Gradiente tonal focal é uma possibilidade futura condicionada a tokens derivados e contraste AA nos dois temas. A implementação atual usa somente o fallback sólido. |
| Um único papel de saldo destacado | `amountHero` legado conserva 34/30px nas composições existentes; `balanceHero`/`balanceHeroCompact` acrescentam 40/34px por largura disponível do componente. |

O registro de execução e seus limites de validação ficam em [`docs/redesign-progress.md`](docs/redesign-progress.md). Nenhuma regra de cálculo, identidade, sincronização ou privacidade financeira foi substituída por esta extensão visual.

## Colors

A paleta combina teal profundo com cinzas frios de viés verde; o tema escuro preserva os mesmos papéis sem inverter a hierarquia.

### Primary

- **Teal de confiança:** ações primárias, seleção de navegação e pequenos sinais de marca.
- **Teal de resposta:** estado hover de ações primárias.
- **Menta de seleção:** fundo de seleção e foco tonal, acompanhado por texto ou ícone teal nesses estados. O mesmo token sustenta a superfície financeira focal sólida.

### Secondary

- **Azul informativo:** foco de campos, informação e identificação visual de cartões de crédito.
- **Verde positivo, vermelho de risco e âmbar de atenção:** semântica financeira e de sistema. Cada tom possui uma superfície suave correspondente.

### Neutral

- **Fundo frio:** base da página.
- **Canvas limpo:** cartões, barra superior, navegação e controles.
- **Superfície alternativa:** hover, itens arquivados e controles secundários.
- **Borda estrutural e borda forte:** separação padrão e reforço interativo.
- **Texto primário, secundário e atenuado:** conteúdo, explicação e metadados, respectivamente.

**The One Voice Rule.** O teal é a única cor de marca. Uma superfície financeira focal por viewport pode usar `financialSurface`; não repetir esse preenchimento em listas, relatórios ou todos os cartões. `financialSurface` é alias de `primarySoft` em cada tema, sem novo hex. Use texto primário ou secundário e cores semânticas financeiras com contraste AA validado; texto atenuado não é usado nessa superfície.

**The Paired Meaning Rule.** Estado nunca depende apenas de cor; combine tom com texto e, quando houver símbolo reconhecível, com ícone.

## Typography

**Display Font:** Inter
**Body Font:** Inter
**Label Font:** Inter

**Character:** Uma única família contemporânea sustenta a interface inteira. A diferença entre conteúdo e ação vem sobretudo de peso, não de saltos dramáticos de tamanho.

### Hierarchy

- **Display:** totais de maior destaque e momentos raros de primeiro nível.
- **Headline:** títulos de página; subtítulos de página e seção usam os degraus implementados de 22px/600 e 18px/600.
- **Title:** nomes de itens e títulos compactos, incluindo nomes de contas e cartões.
- **Body:** texto corrente; a variação grande usa 16px e legendas usam 12px/500.
- **Label:** botões e rótulos de campos.
- **Amount:** dinheiro em linhas e cartões usa 16px/600. `amountHero` legado permanece 34px/600 e conserva a redução compacta de 30px onde já aplicada.
- **Balance hero:** abertura financeira migrada usa `balanceHero` de 40px/600 com pelo menos 600px disponíveis no componente; abaixo disso, `balanceHeroCompact` de 34px/600. Ambos usam entrelinha 1,15 e algarismos tabulares. Selecione por `balanceHeroForWidth`, sem substituir automaticamente o papel legado.
- **Eyebrow:** reservado a cabeçalhos de tabela e divisores de navegação, em caixa alta.

**The Exact Figure Rule.** Todo valor monetário, percentual, data tabular e contagem parcelada usa algarismos tabulares e conserva a exatidão. O adendo de movimento autorizado pelo usuário permite rolagem visual entre estados reais do saldo; não interpola quantias fictícias nem altera o valor semântico atual. Privacidade ou movimento reduzido interrompem o efeito imediatamente.

O saldo faz reflow sem reduzir sua fonte. Em `PrivacyAmount` com `reserveLayout: true` e `allowWrap: true`, prefira quebrar após a moeda e manter o token numérico íntegro; quebras entre grupos numéricos só são liberadas quando o próprio corpo numérico excede a largura disponível. Medição e pintura usam a mesma política. Quando a quebra está habilitada, `MoneyText` conserva a permissão legada de quebra entre grupos por padrão; a política por largura exige adesão explícita do componente pai.

**The Contextual Money Rule.** `MoneySemantic` é sempre declarado pelo significado no contexto: `balance` para saldos, patrimônio e ativos; `debt` para obrigações; `income` e `expense` para fluxos; `neutral` para alvo, reservado e restante. `automatic` só é aceitável quando o próprio sinal define integralmente a natureza. Com texto ampliado, ofereça quebra entre rótulo e valor ou entre ações, preservando o rótulo exato, visível e sem truncamento.

**The Sentence Case Rule.** Use sentence case em títulos, rótulos, botões e badges; caixa alta pertence somente ao eyebrow.

## Layout

O ritmo nasce de uma unidade de 4px e privilegia incrementos de 8px. O conteúdo geral limita-se a 1600px e colunas de leitura de dashboard a 1280px. Telas de formulário podem estreitar a coluna conforme a tarefa; o cadastro de conta/cartão usa uma coluna de até 760px.

O shell é adaptativo. Abaixo de 600px, usa navegação inferior, gutter compacto de 16px e ações principais de largura total quando necessário. A partir de 600px, usa rail lateral e gutter amplo de 24px; a partir de 1024px, o rail pode mostrar rótulos ou ser recolhido manualmente. Seções relacionadas podem ocupar colunas paralelas conforme a largura disponível. No Android, todo alvo interativo mede pelo menos 48dp em qualquer largura.

Na listagem de contas, o primeiro viewport apresenta título, explicação, ação de cadastro e as seções de contas/cartões. As seções ficam lado a lado somente com largura mínima observada de 1040px e quando ambas têm conteúdo; em larguras menores, empilham. Dentro de cada seção, cartões podem formar duas colunas a partir de 880px disponíveis. Campos de fechamento e vencimento também passam de coluna para linha em 600px.

Em transações, busca e filtros precedem sempre o histórico. Abaixo de 600px, os lançamentos são agrupados por dia em uma única coluna e os detalhes abrem em modal raiz, preservando o contexto escurecido da lista. Entre 600px e 1023px, o ledger permanece em uma coluna e também delega os detalhes ao modal. A partir de 1024px, a seleção mantém o ledger visível e abre ao lado um painel contextual fixo de 360px; o painel nunca comprime a coluna a ponto de ocultar valor ou estado.

Na visão geral, a ordem operacional é invariável: cabeçalho com contexto e ação, par de saldos confirmado/projetado, resultado projetado do mês, posições por conta e transações recentes. Com 880px ou mais disponíveis, posições e transações dividem a linha em proporção 4:6; abaixo disso, empilham nessa mesma ordem. O resumo usa composição assimétrica 7:3 a partir de 760px, mantendo os saldos como leitura dominante; em espaço menor, seus cartões empilham. O cabeçalho também empilha no compacto, com seletor de moeda e ação ocupando a largura disponível.

Na fatura de cartão, o desktop apresenta resumo e parcelas futuras antes das compras: com pelo menos 820px disponíveis e escala tipográfica de até 1,3×, resumo e futuro dividem a primeira linha, seguidos pelo ledger de compras em largura total. No mobile, a ordem é resumo, compras e parcelas futuras. Acima de 1,3×, a composição paralela e os pares internos fazem reflow para blocos verticais, sem reduzir tipografia, truncar valores ou ocultar parcelas.

No planejamento, o mês é lido como uma sequência estável de faixas: cabeçalho com navegação de período e moeda, posição planejada, orçamentos por categoria, agenda, assinaturas, lembretes locais e gerenciamento. Orçamentos e agenda dividem a linha somente com pelo menos 860px disponíveis e escala tipográfica de até 1,3×; abaixo disso, empilham nessa ordem, seguidos pelas demais faixas. Cabeçalhos, métricas, ocorrências, lembretes e controles de ciclo de vida também fazem reflow acima de 1,3×, sem esconder valores, estados ou ações.

No patrimônio, o primeiro viewport é um dossiê: cabeçalho e ações antecedem balanço líquido e meta prioritária. Com pelo menos 860px disponíveis e escala tipográfica de até 1,3×, os dois dividem a linha; fora disso, empilham com o balanço antes da meta. A composição rastreável de ativos e dívidas vem em seguida, depois metas e gerenciamento manual, sem separar os totais das fontes que os explicam.

Texto ampliado provoca reflow por conteúdo, não redução tipográfica nem recorte. Acima de 1,3×, o resumo deixa de usar colunas, os pares de rótulo e valor podem virar blocos verticais, os valores ficam alinhados ao fim em uma linha própria e os cabeçalhos de seção colocam a ação abaixo do título. A ordem de leitura, a unidade monetária, os sinais e os estados permanecem íntegros.

**The Same Ledger Rule.** A mudança de largura reorganiza o lançamento, mas preserva descrição, conta ou categoria, data, valor exato e estado na mesma ordem de leitura.

**The Natural Collapse Rule.** A adaptação preserva ordem e hierarquia: colunas viram pilhas, botões ocupam a largura disponível e nenhum dado essencial desaparece.

**The Overview Evidence Rule.** A visão geral sempre progride de posição agregada para explicação por conta e, por fim, para os lançamentos recentes que sustentam os números.

## Elevation & Depth

Superfícies são planas em repouso. Fundo, canvas, mudança tonal e bordas estruturais criam profundidade suficiente. Elevação 1 aparece apenas no hover de cartões interativos; menus, toasts e diálogos usam as elevações nativas 2 e 3. Não há blur, textura, sombra colorida ou sombra interna. A superfície financeira atual é sólida. O plano admite futuramente um gradiente tonal somente no cartão financeiro focal ou abertura mobile, após registrar tokens derivados por tema e validar contraste AA; sem esses requisitos, permanece o fallback sólido. Essa possibilidade não autoriza gradientes em números, gráficos, listas ou fundo da tela.

**The Flat-by-Default Rule.** Uma superfície em repouso não recebe sombra; elevação comunica camada real ou resposta interativa.

## Shapes

A geometria é suavemente arredondada e funcional: chips usam raio pequeno, campos, tabelas e botões usam raio médio, e cartões e diálogos usam raio grande. O raio totalmente circular é exclusivo de badges. Cartões recebem recorte antialias; a borda estrutural de 1px pertence ao padrão `outlined` e a qualquer variante interativa, enquanto `flat` e `financial` informativos a omitem.

**The Honest Radius Rule.** Botões nunca viram pílulas; cada categoria conserva seu degrau de raio.

## Components

### Buttons

Contidos e verbais, os botões priorizam a tarefa sobre a marca.

- **Shape:** retângulo suavemente arredondado com alturas compacta, padrão e proeminente de 32px, 40px e 48px; no Android, qualquer variante mantém alvo mínimo de 48dp em toda largura.
- **Long labels:** `PollarButton.adaptiveHeight` é optativo e permanece `false` por padrão. Em Contas, cadastro e confirmação de arquivamento podem crescer acima do mínimo, preservando rótulo completo, padding e alvo com texto ampliado. Outros botões conservam sua geometria até migração própria.
- **Primary:** teal sólido, texto de alto contraste, ícone opcional de 16px ou 20px e padding horizontal associado ao tamanho.
- **Secondary / Ghost:** canvas com borda forte ou fundo transparente; ambos recebem superfície alternativa no hover.
- **Danger:** vermelho semântico, reservado a ações destrutivas.
- **Hover / Focus / Disabled:** primário escurece no tema claro; foco usa traço informativo de 2px; desabilitado reduz a opacidade para 55%. Não há ripple.
- **Icon button:** controle quadrado, tooltip e nome semântico obrigatórios; seleção combina fundo menta com ícone teal.

### Cards / Containers

Cartões agrupam informação, não decoram a página.

- **Corner Style:** raio grande.
- **Variants:** `PollarCardVariant.outlined` é o padrão legado; `flat` agrupa informação sem borda; `financial` é o papel focal sólido, também sem borda quando informativo. A migração é explícita por instância.
- **Background:** `outlined` e `flat` usam canvas, ou superfície alternativa com `alt: true` para estados como arquivamento. `financial` usa `financialSurface` e esse papel prevalece sobre `alt`.
- **Shadow Strategy:** sem sombra em repouso; cartões interativos de qualquer variante recebem elevação 1 e borda forte no hover.
- **Border / Focus:** padrão `outlined` e qualquer variante com `onTap` mantêm traço de 1px; foco de teclado interativo recebe borda informativa explícita de 2px e semântica de botão. `flat`/`financial` sem ação omitem a borda.
- **Internal Padding:** 0, 12px, 16px ou 20px conforme densidade; 20px é o padrão.
- **Nesting:** cartões não são aninhados.

### Money and Privacy

`MoneyText` e `PrivacyAmount` conservam moeda, sinal, valor exato e significado contextual. A máscara anuncia “Valor oculto pelo modo privacidade” e não expõe o valor original na árvore acessível.

`PrivacyAmount.reserveLayout` é optativo e permanece `false` por padrão. Nos saldos que fazem reflow, ative-o para reservar as dimensões máximas entre texto visível e máscara na largura e escala tipográfica atuais. O valor oculto é apenas medido: não é pintado nem exposto à acessibilidade. A altura reservada pode incluir espaço vazio quando a máscara ocupa menos linhas; isso mantém os blocos seguintes na mesma posição.

### Development Catalogue

A aba **Fundamentos** em `forms_catalog_screen.dart` usa `foundations_catalog.dart` para mostrar superfície financeira, agrupamento sem borda, padrão interativo e privacidade, com dados explicitamente demonstrativos. `tool/design_catalog.dart` inicia essa amostra isolada sem autenticação, perfil ou banco financeiro. É uma ferramenta de desenvolvimento.

O adendo de movimento solicitado pelo usuário é implementado por `PollarMotion`, `PollarRollingAmount` e `PollarKineticCard`, com 140/240/360/700ms, corte por movimento reduzido e privacidade imediata. Saldo, morph cartão/fatura, verso com termos reais, gráficos e meta concluída integram os fluxos atuais sem substituir a composição. `tool/motion_catalog.dart` e `motion_catalog.dart` oferecem uma amostra isolada rotulada. Escopo e exceções às regras anteriores ficam em [`docs/pollar-motion.md`](docs/pollar-motion.md).

Goldens cobrem claro/escuro, larguras 320/390/1440px e texto ampliado, incluindo 1,3× e 2×; testes de widget verificam foco/Enter, contraste e privacidade semântica. A inspeção nativa observou a interface anterior; não equivale a uma verificação física de teclado ou leitor de tela do catálogo atualizado. Capturas de referência incluem `foundations_1440_light_1x.png`, `foundations_390_dark_1x.png` e o par visível/oculto `foundations_320_light_130pct*.png` em `apps/pollar_app/test/goldens/`.

### Inputs / Fields

Campos compartilham geometria e validação nativa, com rótulo sempre visível.

- **Style:** canvas preenchido, borda de 1px, raio médio e padding interno de 16px.
- **Focus:** borda azul informativa de 2px.
- **Error:** borda vermelha; o estado focado mantém 2px.
- **Validation:** ocorre após interação e explica como corrigir o valor.
- **Currency:** texto alinhado à direita, peso de valor e algarismos tabulares; em pt-BR, explicita vírgula decimal e código da moeda.
- **Select:** usa a mesma caixa dos inputs e chevron Lucide de 20px.

### Badges and Feedback

Badges são cápsulas compactas; banners, toasts e modais mantêm a mesma semântica de cores.

- **Badge:** altura de 20px ou 24px, padding horizontal de 8px ou 10px e raio circular exclusivo.
- **Status:** texto de peso 600 e, quando aplicável, ícone de 12px ou 14px; estados semânticos usam cor forte sobre seu preenchimento suave.
- **Transaction status:** Previsto usa tom neutro e relógio; Pendente usa atenção e relógio; Compensado usa sucesso e check; Conciliado usa informação e check; Cancelado usa risco e x. O rótulo textual permanece sempre visível.
- **Feedback:** mensagens nomeiam o que ocorreu e a próxima ação. Modais de arquivamento explicam impacto e preservação do histórico antes da confirmação.

### Navigation

A navegação acompanha a largura sem mudar o mapa mental.

- **Compact:** cinco destinos com texto e ícones Lucide de 24px, barra inferior sobre canvas, borda superior e área segura nativa.
- **Medium:** rail de 72px com ícones de 20px, tooltips e nomes acessíveis completos.
- **Expanded:** rail de 256px com rótulos; controle na barra superior alterna para 72px. A preferência dura a sessão, inclusive após mudar a largura. O controle não reinicia rotas, pilhas ou formulários.
- **Short windows:** marca e destinos do rail rolam juntos; alvos não encolhem nem recebem rótulos em fonte de 9px.
- **Selected:** indicador menta e conteúdo teal; a barra superior é canvas com borda inferior e sem elevação.
- **Header:** contexto de destino em corpo secundário de 14px, tema e privacidade globais. Na lista compacta de Transações, a barra mantém o título de página em 18px e cresce com a escala de texto, pois essa lista não tem outro título no corpo.
- **More:** “Entenda seus dados” reúne Relatórios e Patrimônio; “Seu aplicativo” reúne Sincronização, Dados e backup e Preferências. Linhas com divisores substituem cartões equivalentes; texto quebra naturalmente e o foco recebe contorno informativo de 2px.

### Overview Dashboard

A visão geral funciona como fechamento de caixa imediato: distingue dinheiro disponível, compromissos futuros e resultado do período antes de apresentar sua composição.

- **Summary pair:** uma única superfície `financial` sólida reúne confirmado, projetado e dívida projetada explicitamente separada do caixa. Confirmado usa `balanceHeroForWidth` (40/34px por largura do componente); projetado tem escala de apoio e explica previstos/pendentes.
- **Monthly result:** grupo sem moldura com título de seção, valor de 22px e entradas/saídas; confirma que o resultado é projetado e representa receitas menos despesas do mês, sem competir tipograficamente com o saldo.
- **Reading/action order:** no compacto e em largura insuficiente, posição → mês → Nova transação → contas → transações recentes. No amplo, a ação fica no cabeçalho. Cabeçalho e grade usam largura disponível e texto ampliado, sem esconder o seletor de moeda.
- **Evidence:** listas usam `flat`, títulos de 18px e divisores. Contas preservam nomes completos e valores com largura limitada; transações recentes optam pelo `TransactionTile.reflowContent`, mantendo linhas densas quando descrição, metadados e valor cabem e empilhando quando necessário. Outras instâncias mantêm o padrão até sua fase.
- **Financial semantics:** contas ativas compõem os saldos de caixa; cartões são passivos e sua dívida projetada aparece separadamente. Contas arquivadas não entram nas posições ativas, e transações canceladas podem permanecer no histórico recente sem afetar os totais.
- **Multiple currencies:** totais de moedas diferentes nunca são somados. Quando houver mais de uma moeda, um seletor explícito filtra resumo, posições e transações como uma unidade; o código da moeda permanece visível no contexto do saldo.
- **Privacy:** o controle global oculta todos os valores da superfície de uma vez. `reserveLayout` e `allowWrap` mantêm pegada e valor exato mesmo em texto ampliado; alinhamento reservado pode ser ao fim nas linhas. Nomes, explicações, quantidade de posições, moeda e estados continuam legíveis. O original não entra na semântica oculta.
- **Responsive behavior:** o resumo assimétrico e as duas colunas inferiores existem apenas quando largura e escala tipográfica permitem; o reflow vertical preserva a sequência operacional e mantém valores alinhados ao fim.
- **States:** carregamento informa que a posição está sendo calculada; erro recuperável afirma que os dados permanecem salvos e oferece recalcular; ausência de contas apresenta uma única chamada para cadastrar a primeira conta; ausência apenas de transações preserva o resumo e explica que o saldo inicial já compõe a posição. Vazio e estados compartilhados rolam quando a altura disponível não comporta o conteúdo.
- **No synthetic history:** não introduza gráficos, tendências, comparações históricas, orçamentos ou troca de período sem dados reais e sem a fatia de produto correspondente.

**The Currency Isolation Rule.** Cada moeda constitui uma visão financeira completa e independente; nenhum total, posição ou lançamento de outra moeda atravessa a seleção ativa.

**The Liability Separation Rule.** Dívida de cartão explica a posição, mas nunca é incorporada silenciosamente ao saldo de caixa.

### Reports Ledger

Relatórios formam uma trilha de evidências do livro-caixa, não uma coleção de métricas decorativas: período, critério contábil, comparações e exportação permanecem visíveis e reconciliáveis.

- **Basis:** o período móvel de seis meses usa somente lançamentos compensados e conciliados. Compras de cartão contam como despesa; transferências e pagamentos de fatura ficam fora de receitas e despesas para impedir dupla contagem.
- **First viewport:** contexto de período e moeda antecede exportação, critério contábil e resultado agregado. Entradas e saídas explicam o resultado antes dos gráficos.
- **Monthly flow:** barras comparam entradas e saídas mês a mês sobre uma linha de base. Uma tabela textual com todos os valores exatos acompanha o gráfico e conserva a mesma ordem temporal.
- **Account trend:** a série mostra o saldo líquido das contas ativas a cada fechamento mensal, derivado de saldos iniciais e lançamentos confirmados. Ela declara que avaliações manuais de ativos e dívidas não possuem histórico e não entram na série.
- **Categories:** saídas são ordenadas por valor e apresentadas com nome, quantia exata, percentual e barra linear. Muitas categorias usam barras e lista, nunca um donut ilegível.
- **Verifiable export:** o CSV mantém ordem determinística, moeda e valores assinados em unidades menores; um arquivo lateral SHA-256 permite verificar o conteúdo exportado.
- **Responsive behavior:** com pelo menos 880px disponíveis e escala tipográfica de até 1,3×, fluxo e saldo dividem a linha em proporção 6:4. Fora disso, empilham nessa ordem. Pares de rótulo e valor também fazem reflow antes de competir por espaço.
- **Privacy:** valores textuais, proporções, barras e séries são mascarados globalmente; período, moeda, categorias, critério e espaço estrutural dos gráficos permanecem identificáveis sem revelar magnitude relativa.

**The Report Evidence Rule.** Toda visualização deve ter valores textuais exatos e declarar período, moeda e critério contábil; nenhum gráfico introduz dados sintéticos ou mistura fontes sem histórico compatível.

### Wealth Dossier

Patrimônio é um dossiê verificável, não um número isolado: reúne balanço líquido, meta prioritária e registros manuais sem apresentar avaliações como fatos do livro-caixa.

- **First viewport:** o balanço líquido e a meta prioritária permanecem juntos na abertura; no compacto ou com texto ampliado, o balanço vem primeiro e nenhum dado é removido.
- **Traceable composition:** patrimônio líquido é a soma de saldos confirmados positivos e ativos manuais ativos, menos saldos confirmados negativos e dívidas manuais ativas. Totais de ativos e obrigações apontam para registros com nome, valor exato, origem ou tipo e data de avaliação ou atualização; moedas nunca se misturam.
- **Priority goal:** existe no máximo uma meta prioritária por moeda. Alvo, reservado, restante e progresso são derivados e não movimentam contas.
- **Manual records:** ativos declaram valor conhecido e data de avaliação; dívidas declaram valor original, saldo devedor, taxa anual, vencimento quando houver e data de atualização. Não se presume cotação, amortização ou atualização automática.
- **Management:** metas, ativos e dívidas permanecem acessíveis em uma faixa manual com ações rotuladas de editar, pausar e retomar; metas podem ser concluídas e dívidas, liquidadas, sempre após confirmação explícita. Pausar remove o registro dos totais ou metas visíveis sem apagar sua configuração; concluir e liquidar preservam o registro no gerenciamento.
- **Responsive semantics:** pares de rótulo e valor, identidade e valor, e grupos de ações oferecem pontos de quebra antes de competir por espaço. Texto ampliado preserva integralmente rótulos como “Ativos acompanhados”, “Obrigações acompanhadas”, “Falta reservar” e “Valor alvo”, além do valor exato e de seu `MoneySemantic` contextual.

**The Traceable Net Worth Rule.** Todo patrimônio líquido deve ser reconciliável com os ativos e as dívidas que o compõem, na mesma moeda e sem avaliações automáticas implícitas.

**The Manual Lifecycle Rule.** Editar preserva identidade; pausar é reversível; concluir uma meta e liquidar uma dívida são estados finais confirmados, não exclusões.

### Card Statement

A fatura reconcilia o saldo em aberto com as compras que o formaram e com os compromissos que permanecem nos meses seguintes.

- **Summary:** período e status antecedem o saldo em aberto; total, valor pago, vencimento, limite disponível e percentual utilizado permanecem explícitos e verificáveis. O saldo em aberto e a data de vencimento lideram a hierarquia.
- **Payment:** pagamento integral ou parcial sai de uma conta ativa elegível na mesma moeda e é registrado como transferência para o passivo do cartão, nunca como nova despesa. A confirmação declara esse efeito, mantém conta e valor editáveis e exibe validação visível para valor ausente, não positivo ou superior ao saldo em aberto.
- **Purchases:** compras são agrupadas por data, com subtotal diário, descrição, categoria, valor assinado e posição da parcela quando aplicável.
- **Future installments:** toda parcela futura é apresentada com descrição, competência, posição completa e valor, seguida pelo total comprometido; listas não recebem limite arbitrário nem corte silencioso.
- **Responsive behavior:** no desktop, resumo e parcelas futuras formam a abertura e as compras vêm depois; no mobile, a sequência é resumo, compras e parcelas futuras. Escala tipográfica acima de 1,3× força reflow vertical de colunas, métricas e pares de parcela/valor, preservando todo o conteúdo.
- **Purchase entry:** “Adicionar compra” abre o formulário de transação com o cartão da fatura já pré-selecionado, mantendo o contexto sem impedir revisão.

**The Statement Reconciliation Rule.** Toda fatura deve permitir percorrer saldo em aberto, compras datadas e parcelas futuras sem lacunas, duplicação contábil ou conteúdo omitido.

### Transaction Ledger

O ledger privilegia comparação vertical rápida: identidade à esquerda, consequência financeira e estado à direita.

- **Controls:** a busca consulta descrição ou categoria e combina com Todas, Receitas, Despesas e Transferências. Com pelo menos 960px disponíveis e texto até 1,3×, tipos usam chips contornados; abaixo disso, seletor nativo rotulado Tipo. Busca e seletor empilham abaixo de 600px ou com texto ampliado. Contagem informa o resultado; “Limpar busca e filtro” restaura ambos sem alterar registros.
- **Filter meaning:** Despesas inclui despesas e compras no cartão; Transferências inclui transferências e pagamentos de fatura. Canceladas continuam no histórico e nos filtros correspondentes.
- **Row anatomy:** ícone de natureza, descrição, categoria e conta formam o bloco de identidade; data, valor assinado e badge formam o bloco financeiro. Linhas migradas usam `reflowContent`: nomes e metadados completos, dinheiro com quebra e geometria reservada em privacidade. O padrão dos consumidores legados permanece.
- **Desktop:** uma única superfície plana e contornada recebe cabeçalho eyebrow, divisores de 1px e linhas densas; a linha selecionada usa fundo menta sem remover sua borda ou qualquer dado.
- **Mobile:** cada dia recebe um título textual como Hoje, Ontem ou a data localizada e um único grupo `flat` sem padding externo entre linhas, separadas por divisores de 1px. Controles e lista rolam juntos com menos de 600px disponíveis, altura inferior a 500px ou escala acima de 1,3×; a busca mantém texto e foco ao mudar de composição.
- **Amounts:** receitas exibem sinal positivo e verde; saídas exibem sinal negativo. Transferências continuam identificadas por tipo, conta e ícone, sem serem apresentadas como receita ou despesa.
- **Privacy:** ocultar valores conserva alinhamento, largura e sinais de estado; descrição, tipo, conta, data e badge permanecem legíveis.

### Transaction Detail

O detalhe confirma o significado do lançamento antes de oferecer uma ação de ciclo de vida.

- **Desktop:** painel contextual de 360px somente com pelo menos 1020px disponíveis após rail e gutters, reservando 640px ao ledger e 20px de intervalo. Descrição, badge, valor e campos rolam entre cabeçalho e ação. Sem essa largura, ou com composição rolável, abre modal raiz; no desktop, seu conteúdo tem viewport limitado e rolável. Seleção excluída pela busca ou tipo deixa de exibir painel.
- **Mobile:** modal raiz em folha inferior com alça, ícone de natureza, título, tipo, badge e valor antes dos campos; a ação segura de fechar permanece explícita e separada da ação destrutiva. Ações adotam altura adaptável para rótulos ampliados.
- **Privacy and money:** painel e modal observam a privacidade atual, inclusive durante a abertura. Valores quebram e reservam geometria; receitas e despesas declaram seu significado financeiro, transferências e pagamentos de fatura usam semântica neutra.
- **Fields:** tipo, conta, data e categoria usam pares verticais de rótulo atenuado e valor primário; origem e destino substituem conta única quando a natureza exigir.
- **Cancellation:** “Cancelar transação” altera o estado e mantém o lançamento no histórico. A confirmação explica que o item deixará de afetar os saldos confirmado e projetado; “Manter transação” é a saída segura.

### Transaction Form

O cadastro expõe regras financeiras progressivamente, sem transferir a estrutura contábil para a pessoa usuária.

- **Structure:** cabeçalho com retorno, título e explicação antecede um único cartão; Movimento vem antes de Classificação, e transferências renomeiam o segundo grupo para Origem e destino.
- **Fields:** tipo controla conta elegível, sugestões e campos seguintes; transferências exigem contas comuns distintas e da mesma moeda. Data e estado ficam lado a lado quando houver largura e empilham no compacto.
- **Amount:** aceita magnitude positiva, mantém moeda explícita e orienta a entrada decimal localizada; o domínio determina o sinal e o tratamento de compra no cartão.
- **Action:** salvar fica ao fim no desktop, ocupa a largura disponível no mobile e anuncia carregamento; erros preservam o preenchimento e explicam o que revisar.
- **Unsaved exit:** só interrompe a saída quando houver mudanças. A confirmação distingue “Continuar preenchendo”, ação segura, de “Descartar transação”, ação destrutiva, e esclarece que os dados serão perdidos sem qualquer saldo ter sido alterado.

### Accounts and Credit Cards

Esta listagem apresenta cadastro financeiro, não o saldo corrente do livro-caixa. Contas e Arquivadas são grupos `flat` com linhas e divisores; cartões de crédito mantêm contorno e interação próprios.

- **Identity:** nomes completos, tipo e código da moeda; ícones de 16px/20px em blocos de 24px/32px conforme densidade. Contas usam menta/teal e crédito usa azul informativo.
- **Financial truth:** valores continuam `openingBalance`, rotulados Saldo inicial / Dívida inicial, com semântica de saldo/dívida. Limite tem semântica neutra. Não há soma de moedas, passivos ou novo total agregado.
- **Density:** com 320px disponíveis na linha e texto padrão, identidade, valor e ação dividem a linha. Largura insuficiente ou texto ampliado empilham conteúdo, sem reduzir fonte ou truncar valores/nomes. Grupos ficam paralelos somente com 980px disponíveis e escala até 1,3×.
- **Credit:** flip, tilt e morph para a fatura existente são preservados. Limite/ciclo empilham abaixo de 420px ou acima de 1,3×. Frente e verso mostram somente termos cadastrados; “Ver fatura” continua explícito.
- **Privacy:** todos os valores da listagem quebram com `allowWrap` e reservam geometria com `reserveLayout`, inclusive limite e verso. Ocultação mantém contexto e remove valores acessíveis.
- **Lifecycle:** arquivar confirma e preserva histórico; restaurar continua direto e rotulado. Arquivadas usam superfície alternativa e conservam termos de crédito. Havendo apenas arquivadas, o vazio diz “Nenhuma conta ativa” e orienta restaurar, sem alegar ausência de cadastro.

### Account Form

O cadastro é uma tarefa dedicada, não uma extensão do cartão de listagem.

- **Entry:** botão de retorno rotulado, título e explicação precedem um único cartão de formulário.
- **Progressive disclosure:** tipo de conta controla rótulo, ícone e campos; limite e ciclo aparecem apenas para cartão de crédito.
- **Grouping:** seções de identificação e posição financeira usam subtítulos e espaçamento, sem cartões internos.
- **Action:** salvar fica alinhado ao fim no desktop e ocupa a largura completa no mobile; durante o salvamento, a ação é desabilitada e anuncia carregamento.

### Recurring Planning

O planejamento mensal reconcilia limites, gasto registrado e compromissos projetados sem apresentar previsões como fatos do livro-caixa.

- **Monthly position:** total orçado, gasto registrado, disponível no orçamento e compromissos de saída abrem a leitura do mês; o período e a moeda selecionados governam toda a superfície.
- **Category budgets:** cada categoria mostra gasto e limite exatos, barra de progresso, percentual e estado textual com ícone — Dentro do limite, Próximo do limite ou Limite excedido. O progresso é evidência de reconciliação, não pontuação ou meta gamificada.
- **Recurring agenda:** entradas, pagamentos e assinaturas ativos aparecem em ordem de vencimento com data, natureza e valor assinado. Criar uma recorrência apenas projeta ocorrências; nenhuma transação é lançada automaticamente.
- **Subscriptions and reminders:** assinaturas recebem faixa própria e total verificável. Lembretes declaram que vivem neste dispositivo, surgem dentro da antecedência configurada e distinguem hoje, prazo futuro e data passada por texto e ícone; não prometem notificação do sistema operacional.
- **Lifecycle:** a faixa de gerenciamento conserva itens ativos e pausados. Pausar remove o item dos totais, agenda ou lembretes aplicáveis sem apagar a configuração; retomar o reintegra. Badge, verbo de ação, confirmação de impacto e feedback de sucesso ou falha tornam a recuperação explícita.
- **Async forms:** modais de criação não são descartáveis durante a tarefa. Enquanto a persistência está pendente, cancelar e salvar ficam indisponíveis e a ação primária anuncia carregamento; o modal fecha somente após sucesso. Em falha, permanece aberto, preserva os campos e apresenta uma mensagem corrigível para nova tentativa.

**The Plan Is Not the Ledger Rule.** Orçamentos, ocorrências e lembretes explicam o mês futuro, mas nunca simulam uma transação já registrada.

**The Recoverable Pause Rule.** Pausar é reversível e preserva a configuração; estado e consequência devem ser declarados antes da mudança.

### Identidade e sincronização

A entrada funciona como um limiar de privacidade, não como campanha de
aquisição: propósito e garantias locais precedem o formulário. Em largura ampla,
contexto e formulário dividem duas colunas; no compacto, contexto, garantias e
formulário formam uma única sequência rolável.

O formulário de entrada usa código de e-mail, sem campo de senha. O segundo
passo mostra o código TOTP como ação principal e, somente em dispositivo já
confirmado, a alternativa nativa de biometria/PIN (Windows Hello no desktop).
Quando o servidor está indisponível, a alternativa local preserva o acesso ao
livro-caixa sem afirmar que houve nova verificação remota.

A superfície de sincronização é um console do livro-caixa. Status, contagem exata
da fila e ação principal ocupam a primeira faixa; identidade e conflitos vêm
depois. Conflitos sempre mostram que as duas versões foram preservadas e exigem
uma comparação antes das escolhas “usar servidor” e “manter deste dispositivo”.
Em texto ampliado, títulos e badges quebram para linhas independentes.

**The Visible Replication Rule.** Sincronização nunca é uma promessa abstrata de
nuvem: fila, último sucesso, falha recuperável e conflito têm texto e estado
visíveis. Nenhuma divergência financeira é resolvida apenas por cor ou em
silêncio.

## Do's and Don'ts

### Do:

- **Do** ler cores e medidas dos tokens de tema em vez de codificar valores nos widgets.
- **Do** manter contas e cartões identificáveis por texto, ícone e tratamento tonal; o azul informativo distingue cartões sem criar uma segunda cor de marca.
- **Do** separar configuração, ciclo de vida e cadastro de conta dos lançamentos financeiros.
- **Do** usar verbos que nomeiam o objeto da ação, como cadastrar, salvar, arquivar e restaurar.
- **Do** preservar valores exatos, formatação pt-BR, algarismos tabulares, modo privacidade e rótulos acessíveis.
- **Do** empilhar seções e campos no compacto, usar gutters de 16px no compacto e 24px no amplo e, no Android, manter alvos de toque de pelo menos 48dp em qualquer largura.
- **Do** manter valor e estado escaneáveis no ledger, inclusive com texto ampliado, seleção ativa e modo privacidade.
- **Do** agrupar transações por dia no mobile e manter o ledger visível ao abrir o painel contextual no desktop expandido.
- **Do** explicar separadamente o impacto de cancelar uma transação persistida e de descartar um rascunho não salvo, oferecendo uma ação segura inequívoca em ambos os casos.
- **Do** manter, na visão geral, o par confirmado/projetado antes do resultado mensal e das listas que explicam esses totais.
- **Do** separar totais por moeda, filtrar toda a superfície pela moeda ativa e mostrar dívidas de cartão fora do saldo de caixa.
- **Do** fazer reflow da visão geral quando o texto ultrapassar 1,3×, preservando conteúdo, sinais, moeda, estados e alinhamento dos valores.
- **Do** oferecer estados de carregamento, erro recuperável, primeira conta e ausência de transações com próximo passo específico e sem sugerir perda de dados.
- **Do** preservar a ordem mensal posição, orçamentos, agenda, assinaturas, lembretes e gerenciamento quando faixas paralelas virarem uma pilha.
- **Do** reconciliar cada orçamento com gasto, limite, percentual e estado explícito, mantendo os valores ocultáveis sem remover sua relação.
- **Do** manter formulários de planejamento abertos durante a persistência e, em falha, conservar os campos preenchidos para nova tentativa.
- **Do** manter balanço e meta prioritária no primeiro viewport do patrimônio e tornar seus totais reconciliáveis com ativos, dívidas e datas de referência.
- **Do** declarar `MoneySemantic` pelo contexto e criar pontos de quebra que preservem rótulo, valor exato e ação sob texto ampliado.

### Don't:

- **Don't** repetir a superfície teal focal em vários blocos do viewport ou depender apenas de cor para significado.
- **Don't** adicionar gradientes sem os tokens e a validação exigidos para a exceção focal futura; a fase 1 usa superfície sólida. Vidro, blur, textura, padrões, sombras coloridas, sombras internas e imagens de fundo continuam fora do sistema.
- **Don't** aninhar cartões, transformar botões em pílulas ou elevar superfícies estáticas.
- **Don't** misturar famílias de ícones, usar emoji como ícone ou deixar um controle apenas com ícone sem tooltip e nome acessível.
- **Don't** esconder conteúdo essencial no layout compacto nem misturar campos específicos de cartão em contas comuns.
- **Don't** interpolar quantias financeiras fictícias, arredondar totais ou abreviar valores de interface. A rolagem visual autorizada do saldo usa somente os estados reais anterior/atual.
- **Don't** substituir rótulos de estado, sinais monetários ou ícones de natureza por cor isolada.
- **Don't** abrir detalhes em um cartão aninhado no mobile nem trocar o painel contextual de 360px por navegação que remova o ledger no desktop expandido.
- **Don't** tratar cancelamento como exclusão: o lançamento continua no histórico e seu efeito sobre os saldos deve ser declarado antes da confirmação.
- **Don't** somar moedas, incorporar dívida de cartão ao caixa ou confundir saldo confirmado com valores previstos e pendentes.
- **Don't** ocultar rótulos, moeda, estado ou estrutura no modo privacidade; somente os valores monetários recebem máscara estável.
- **Don't** comprimir a visão geral com texto ampliado, truncar valores ou reduzir a fonte para conservar colunas.
- **Don't** inventar gráficos históricos, tendências, metas ou comparações de período para preencher a visão geral.
- **Don't** apresentar recorrências, assinaturas ou lembretes locais como transações confirmadas ou como notificações entregues pelo sistema operacional.
- **Don't** apagar a configuração ao pausar um orçamento ou compromisso, nem ocultar itens pausados da área em que podem ser retomados.
- **Don't** permitir descarte ou envios duplicados enquanto um formulário de planejamento estiver salvando.
- **Don't** apresentar patrimônio líquido sem composição rastreável, tratar registros manuais como cotações automáticas ou remover itens pausados, concluídos e liquidados do gerenciamento.
