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

Em transações, busca e filtros precedem sempre o histórico. Abaixo de 600px, os lançamentos são agrupados por dia em uma única coluna e os detalhes abrem em modal raiz, preservando o contexto escurecido da lista. Entre 600px e 1023px, o ledger permanece em uma coluna e também delega os detalhes ao modal. A partir de 1024px, a seleção mantém o ledger visível e abre ao lado um painel contextual fixo de 360px; o painel nunca comprime a coluna a ponto de ocultar valor ou estado.

Na visão geral, a ordem operacional é invariável: cabeçalho com contexto e ação, par de saldos confirmado/projetado, resultado projetado do mês, posições por conta e transações recentes. Com 880px ou mais disponíveis, posições e transações dividem a linha em proporção 4:6; abaixo disso, empilham nessa mesma ordem. O resumo usa composição assimétrica 7:3 a partir de 760px, mantendo os saldos como leitura dominante; em espaço menor, seus cartões empilham. O cabeçalho também empilha no compacto, com seletor de moeda e ação ocupando a largura disponível.

Texto ampliado provoca reflow por conteúdo, não redução tipográfica nem recorte. Acima de 1,3×, o resumo deixa de usar colunas, os pares de rótulo e valor podem virar blocos verticais, os valores ficam alinhados ao fim em uma linha própria e os cabeçalhos de seção colocam a ação abaixo do título. A ordem de leitura, a unidade monetária, os sinais e os estados permanecem íntegros.

**The Same Ledger Rule.** A mudança de largura reorganiza o lançamento, mas preserva descrição, conta ou categoria, data, valor exato e estado na mesma ordem de leitura.

**The Natural Collapse Rule.** A adaptação preserva ordem e hierarquia: colunas viram pilhas, botões ocupam a largura disponível e nenhum dado essencial desaparece.

**The Overview Evidence Rule.** A visão geral sempre progride de posição agregada para explicação por conta e, por fim, para os lançamentos recentes que sustentam os números.

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
- **Transaction status:** Previsto usa tom neutro e relógio; Pendente usa atenção e relógio; Compensado usa sucesso e check; Conciliado usa informação e check; Cancelado usa risco e x. O rótulo textual permanece sempre visível.
- **Feedback:** mensagens nomeiam o que ocorreu e a próxima ação. Modais de arquivamento explicam impacto e preservação do histórico antes da confirmação.

### Navigation

A navegação acompanha a largura sem mudar o mapa mental.

- **Compact:** barra inferior sobre canvas, separada por borda superior, com ícones Lucide de 24px.
- **Medium:** rail de 72px com ícones de 20px.
- **Expanded:** rail de 256px com rótulos.
- **Selected:** indicador menta e conteúdo teal; a barra superior é canvas com borda inferior e sem elevação.

### Overview Dashboard

A visão geral funciona como fechamento de caixa imediato: distingue dinheiro disponível, compromissos futuros e resultado do período antes de apresentar sua composição.

- **Summary pair:** saldo confirmado e saldo projetado formam um par explícito; confirmado lidera visualmente e projetado declara que inclui lançamentos previstos e pendentes.
- **Monthly result:** resultado projetado é receitas menos despesas do mês e expõe entradas e saídas como componentes verificáveis, nunca como métrica isolada ou gamificada.
- **Financial semantics:** contas ativas compõem os saldos de caixa; cartões são passivos e sua dívida projetada aparece separadamente. Contas arquivadas não entram nas posições ativas, e transações canceladas podem permanecer no histórico recente sem afetar os totais.
- **Multiple currencies:** totais de moedas diferentes nunca são somados. Quando houver mais de uma moeda, um seletor explícito filtra resumo, posições e transações como uma unidade; o código da moeda permanece visível no contexto do saldo.
- **Privacy:** o controle global oculta todos os valores da superfície de uma vez. A máscara mantém símbolo monetário, pegada visual, alinhamento e hierarquia; nomes, explicações, quantidade de posições, moeda e estados continuam legíveis.
- **Responsive behavior:** o resumo assimétrico e as duas colunas inferiores existem apenas quando largura e escala tipográfica permitem; o reflow vertical preserva a sequência operacional e mantém valores alinhados ao fim.
- **States:** carregamento informa que a posição está sendo calculada; erro recuperável afirma que os dados permanecem salvos e oferece recalcular; ausência de contas apresenta uma única chamada para cadastrar a primeira conta; ausência apenas de transações preserva o resumo e explica que o saldo inicial já compõe a posição.
- **No synthetic history:** não introduza gráficos, tendências, comparações históricas, orçamentos ou troca de período sem dados reais e sem a fatia de produto correspondente.

**The Currency Isolation Rule.** Cada moeda constitui uma visão financeira completa e independente; nenhum total, posição ou lançamento de outra moeda atravessa a seleção ativa.

**The Liability Separation Rule.** Dívida de cartão explica a posição, mas nunca é incorporada silenciosamente ao saldo de caixa.

### Transaction Ledger

O ledger privilegia comparação vertical rápida: identidade à esquerda, consequência financeira e estado à direita.

- **Controls:** a busca consulta descrição ou categoria; filtros de Todas, Receitas, Despesas e Transferências usam chips contornados, com check, borda teal e fundo menta apenas no selecionado.
- **Row anatomy:** ícone de natureza, descrição, categoria e conta formam o bloco de identidade; data, valor assinado e badge formam o bloco financeiro. Metadados podem truncar antes do valor ou do estado.
- **Desktop:** uma única superfície plana e contornada recebe cabeçalho eyebrow, divisores de 1px e linhas densas; a linha selecionada usa fundo menta sem remover sua borda ou qualquer dado.
- **Mobile:** cada dia recebe um título textual como Hoje, Ontem ou a data localizada e um único cartão sem padding externo entre linhas, separadas por divisores de 1px.
- **Amounts:** receitas exibem sinal positivo e verde; saídas exibem sinal negativo. Transferências continuam identificadas por tipo, conta e ícone, sem serem apresentadas como receita ou despesa.
- **Privacy:** ocultar valores conserva alinhamento, largura e sinais de estado; descrição, tipo, conta, data e badge permanecem legíveis.

### Transaction Detail

O detalhe confirma o significado do lançamento antes de oferecer uma ação de ciclo de vida.

- **Desktop:** painel contextual de 360px, plano e contornado, alinhado à altura do ledger; título, fechar, descrição, badge e valor antecedem os campos rotulados.
- **Mobile:** modal raiz em folha inferior com alça, ícone de natureza, título, tipo, fechar e valor antes dos campos; a ação segura de fechar permanece explícita e separada da ação destrutiva.
- **Fields:** tipo, conta, data e categoria usam pares verticais de rótulo atenuado e valor primário; origem e destino substituem conta única quando a natureza exigir.
- **Cancellation:** “Cancelar transação” altera o estado e mantém o lançamento no histórico. A confirmação explica que o item deixará de afetar os saldos confirmado e projetado; “Manter transação” é a saída segura.

### Transaction Form

O cadastro expõe regras financeiras progressivamente, sem transferir a estrutura contábil para a pessoa usuária.

- **Structure:** cabeçalho com retorno, título e explicação antecede um único cartão; Movimento vem antes de Classificação, e transferências renomeiam o segundo grupo para Origem e destino.
- **Fields:** tipo controla conta elegível, sugestões e campos seguintes; transferências exigem contas comuns distintas e da mesma moeda. Data e estado ficam lado a lado quando houver largura e empilham no compacto.
- **Amount:** aceita magnitude positiva, mantém moeda explícita e orienta a entrada decimal localizada; o domínio determina o sinal e o tratamento de compra no cartão.
- **Action:** salvar fica ao fim no desktop, ocupa a largura disponível no mobile e anuncia carregamento; erros preservam o preenchimento e explicam o que revisar.
- **Unsaved exit:** só interrompe a saída quando houver mudanças. A confirmação distingue “Continuar preenchendo”, ação segura, de “Descartar transação”, ação destrutiva, e esclarece que os dados serão perdidos sem qualquer saldo ter sido alterado.

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
- **Do** manter valor e estado escaneáveis no ledger, inclusive com texto ampliado, seleção ativa e modo privacidade.
- **Do** agrupar transações por dia no mobile e manter o ledger visível ao abrir o painel contextual no desktop expandido.
- **Do** explicar separadamente o impacto de cancelar uma transação persistida e de descartar um rascunho não salvo, oferecendo uma ação segura inequívoca em ambos os casos.
- **Do** manter, na visão geral, o par confirmado/projetado antes do resultado mensal e das listas que explicam esses totais.
- **Do** separar totais por moeda, filtrar toda a superfície pela moeda ativa e mostrar dívidas de cartão fora do saldo de caixa.
- **Do** fazer reflow da visão geral quando o texto ultrapassar 1,3×, preservando conteúdo, sinais, moeda, estados e alinhamento dos valores.
- **Do** oferecer estados de carregamento, erro recuperável, primeira conta e ausência de transações com próximo passo específico e sem sugerir perda de dados.

### Don't:

- **Don't** usar teal como preenchimento decorativo amplo ou depender apenas de cor para significado.
- **Don't** adicionar gradientes, vidro, blur, textura, padrões, sombras coloridas, sombras internas ou imagens de fundo.
- **Don't** aninhar cartões, transformar botões em pílulas ou elevar superfícies estáticas.
- **Don't** misturar famílias de ícones, usar emoji como ícone ou deixar um controle apenas com ícone sem tooltip e nome acessível.
- **Don't** esconder conteúdo essencial no layout compacto nem misturar campos específicos de cartão em contas comuns.
- **Don't** animar dígitos financeiros, arredondar totais ou abreviar valores de interface.
- **Don't** substituir rótulos de estado, sinais monetários ou ícones de natureza por cor isolada.
- **Don't** abrir detalhes em um cartão aninhado no mobile nem trocar o painel contextual de 360px por navegação que remova o ledger no desktop expandido.
- **Don't** tratar cancelamento como exclusão: o lançamento continua no histórico e seu efeito sobre os saldos deve ser declarado antes da confirmação.
- **Don't** somar moedas, incorporar dívida de cartão ao caixa ou confundir saldo confirmado com valores previstos e pendentes.
- **Don't** ocultar rótulos, moeda, estado ou estrutura no modo privacidade; somente os valores monetários recebem máscara estável.
- **Don't** comprimir a visão geral com texto ampliado, truncar valores ou reduzir a fonte para conservar colunas.
- **Don't** inventar gráficos históricos, tendências, metas ou comparações de período para preencher a visão geral.
