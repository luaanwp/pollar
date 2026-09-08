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
  text-muted: "#74827E"
  success: "#16834F"
  success-soft: "#E8F5EE"
  danger: "#C53B3B"
  danger-soft: "#FBECEC"
  warning: "#A86508"
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

O sistema usa superfícies planas, neutros levemente esverdeados e uma única voz de marca em teal. Hierarquia vem de peso tipográfico, espaçamento e bordas finas, não de ornamentação. Interações mantêm a familiaridade nativa do Flutter/Material 3, enquanto componentes Pollar fixam cor, forma e densidade.

**Key Characteristics:**

- Interface de operação calma, compacta e legível.
- Duas superfícies principais por tela: fundo e canvas.
- Teal raro, reservado a ação, seleção e identidade.
- Estrutura por bordas de 1px e mudanças tonais discretas.
- Valores financeiros exatos, alinhados por algarismos tabulares e ocultáveis sem mudar o layout.
- Iconografia Lucide de contorno arredondado, sempre com rótulo acessível quando o controle não tem texto.

## Colors

A paleta combina teal profundo com cinzas frios de viés verde; o tema escuro preserva os mesmos papéis sem inverter a hierarquia.

### Primary

- **Teal de confiança:** ações primárias, seleção de navegação e pequenos sinais de marca.
- **Teal de resposta:** estado hover de ações primárias.
- **Menta de seleção:** fundo de seleção e foco tonal; deve vir acompanhado por texto ou ícone teal.

### Secondary

- **Azul informativo:** foco de campos, informação e identificação visual de cartões de crédito.
- **Verde positivo, vermelho de risco e âmbar de atenção:** semântica financeira e de sistema. Cada tom possui uma superfície suave correspondente.

### Neutral

- **Fundo frio:** base da página.
- **Canvas limpo:** cartões, barra superior, navegação e controles.
- **Superfície alternativa:** hover, itens arquivados e controles secundários.
- **Borda estrutural e borda forte:** separação padrão e reforço interativo.
- **Texto primário, secundário e atenuado:** conteúdo, explicação e metadados, respectivamente.

**The One Voice Rule.** O teal é a única cor de marca e não funciona como decoração de superfícies extensas.

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
- **Amount:** dinheiro em linhas e cartões; o total de destaque usa 34px/600.
- **Eyebrow:** reservado a cabeçalhos de tabela e divisores de navegação, em caixa alta.

**The Exact Figure Rule.** Todo valor monetário, percentual, data tabular e contagem parcelada usa algarismos tabulares; valores não são abreviados nem têm os dígitos animados.

**The Sentence Case Rule.** Use sentence case em títulos, rótulos, botões e badges; caixa alta pertence somente ao eyebrow.

## Layout

O ritmo nasce de uma unidade de 4px e privilegia incrementos de 8px. O conteúdo geral limita-se a 1600px e colunas de leitura de dashboard a 1280px. Telas de formulário podem estreitar a coluna conforme a tarefa; o cadastro de conta/cartão usa uma coluna de até 760px.

O shell é adaptativo. Abaixo de 600px, usa navegação inferior, gutter de 16px, alvos de toque com pelo menos 44px e ações principais de largura total quando necessário. A partir de 600px, usa rail lateral e gutter de 24px; a partir de 1024px, o rail mostra rótulos e seções relacionadas podem ocupar colunas paralelas.

Na listagem de contas, o primeiro viewport apresenta título, explicação, ação de cadastro e as seções de contas/cartões. As seções ficam lado a lado somente com largura mínima observada de 1040px e quando ambas têm conteúdo; em larguras menores, empilham. Dentro de cada seção, cartões podem formar duas colunas a partir de 880px disponíveis. Campos de fechamento e vencimento também passam de coluna para linha em 600px.

**The Natural Collapse Rule.** A adaptação preserva ordem e hierarquia: colunas viram pilhas, botões ocupam a largura disponível e nenhum dado essencial desaparece.

## Elevation & Depth

Superfícies são planas em repouso. Fundo, canvas, mudança tonal e bordas de 1px criam profundidade suficiente. Elevação 1 aparece apenas no hover de cartões interativos; menus, toasts e diálogos usam as elevações nativas 2 e 3. Não há blur, gradiente, textura, sombra colorida ou sombra interna.

**The Flat-by-Default Rule.** Uma superfície em repouso não recebe sombra; elevação comunica camada real ou resposta interativa.

## Shapes

A geometria é suavemente arredondada e funcional: chips usam raio pequeno, campos, tabelas e botões usam raio médio, e cartões e diálogos usam raio grande. O raio totalmente circular é exclusivo de badges. Cartões recebem recorte antialias e uma borda estrutural de 1px.

**The Honest Radius Rule.** Botões nunca viram pílulas; cada categoria conserva seu degrau de raio.

## Components

### Buttons

Contidos e verbais, os botões priorizam a tarefa sobre a marca.

- **Shape:** retângulo suavemente arredondado com alturas compacta, padrão e proeminente de 32px, 40px e 48px; no mobile, o mínimo é 44px.
- **Primary:** teal sólido, texto de alto contraste, ícone opcional de 16px ou 20px e padding horizontal associado ao tamanho.
- **Secondary / Ghost:** canvas com borda forte ou fundo transparente; ambos recebem superfície alternativa no hover.
- **Danger:** vermelho semântico, reservado a ações destrutivas.
- **Hover / Focus / Disabled:** primário escurece no tema claro; foco usa traço informativo de 2px; desabilitado reduz a opacidade para 55%. Não há ripple.
- **Icon button:** controle quadrado, tooltip e nome semântico obrigatórios; seleção combina fundo menta com ícone teal.

### Cards / Containers

Cartões agrupam informação, não decoram a página.

- **Corner Style:** raio grande.
- **Background:** canvas; a variação alternativa usa a superfície alternativa para estados como arquivamento.
- **Shadow Strategy:** sem sombra em repouso; cartões interativos recebem elevação 1 e borda forte no hover.
- **Border:** traço estrutural de 1px.
- **Internal Padding:** 0, 12px, 16px ou 20px conforme densidade; 20px é o padrão.
- **Nesting:** cartões não são aninhados.

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
- **Feedback:** mensagens nomeiam o que ocorreu e a próxima ação. Modais de arquivamento explicam impacto e preservação do histórico antes da confirmação.

### Navigation

A navegação acompanha a largura sem mudar o mapa mental.

- **Compact:** barra inferior sobre canvas, separada por borda superior, com ícones Lucide de 24px.
- **Medium:** rail de 72px com ícones de 20px.
- **Expanded:** rail de 256px com rótulos.
- **Selected:** indicador menta e conteúdo teal; a barra superior é canvas com borda inferior e sem elevação.

### Account Card

O cartão de conta torna identidade, tipo e posição financeira escaneáveis antes de expor qualquer operação.

- **Identity:** ícone de 20px dentro de bloco 40px com raio médio; contas usam menta/teal e cartões de crédito usam azul informativo suave/forte.
- **Content:** nome e tipo primeiro; saldo ou dívida inicial em seguida. Cartões acrescentam limite e ciclo após divisor de 1px.
- **Privacy:** ocultar um valor preserva sua pegada visual e fornece descrição acessível.
- **Lifecycle:** arquivar e restaurar são ações rotuladas; itens arquivados usam superfície alternativa e ficam em seção separada.

### Account Form

O cadastro é uma tarefa dedicada, não uma extensão do cartão de listagem.

- **Entry:** botão de retorno rotulado, título e explicação precedem um único cartão de formulário.
- **Progressive disclosure:** tipo de conta controla rótulo, ícone e campos; limite e ciclo aparecem apenas para cartão de crédito.
- **Grouping:** seções de identificação e posição financeira usam subtítulos e espaçamento, sem cartões internos.
- **Action:** salvar fica alinhado ao fim no desktop e ocupa a largura completa no mobile; durante o salvamento, a ação é desabilitada e anuncia carregamento.

## Do's and Don'ts

### Do:

- **Do** ler cores e medidas dos tokens de tema em vez de codificar valores nos widgets.
- **Do** manter contas e cartões identificáveis por texto, ícone e tratamento tonal; o azul informativo distingue cartões sem criar uma segunda cor de marca.
- **Do** separar configuração, ciclo de vida e cadastro de conta dos lançamentos financeiros.
- **Do** usar verbos que nomeiam o objeto da ação, como cadastrar, salvar, arquivar e restaurar.
- **Do** preservar valores exatos, formatação pt-BR, algarismos tabulares, modo privacidade e rótulos acessíveis.
- **Do** empilhar seções e campos no mobile, mantendo alvos de toque de pelo menos 44px.

### Don't:

- **Don't** usar teal como preenchimento decorativo amplo ou depender apenas de cor para significado.
- **Don't** adicionar gradientes, vidro, blur, textura, padrões, sombras coloridas, sombras internas ou imagens de fundo.
- **Don't** aninhar cartões, transformar botões em pílulas ou elevar superfícies estáticas.
- **Don't** misturar famílias de ícones, usar emoji como ícone ou deixar um controle apenas com ícone sem tooltip e nome acessível.
- **Don't** esconder conteúdo essencial no layout compacto nem misturar campos específicos de cartão em contas comuns.
- **Don't** animar dígitos financeiros, arredondar totais ou abreviar valores de interface.
