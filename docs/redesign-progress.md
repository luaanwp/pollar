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

## Fase 3 — Visão geral

Implementação em 2026-10-23:

- Uma superfície financeira sólida destaca o confirmado em 40/34px conforme a
  largura real; projetado e dívida de cartão conservam seus significados.
- O resultado projetado mensal usa escala de apoio, sem moldura equivalente.
  Entradas e saídas continuam explícitas. No layout empilhado, “Nova transação”
  vem depois dos dois resumos; no amplo, permanece no cabeçalho.
- Contas e transações recentes usam agrupamentos planos, títulos de 18px e
  divisores. A grade empilha acima de 1,3×; não usa só o tamanho da janela.
- Valores têm largura limitada, quebra e reserva da geometria em privacidade.
  Nomes de conta e descrições principais não são truncados. O reflow optativo
  do TransactionTile mantém linhas densas quando o conteúdo cabe, preservando
  o padrão das instâncias de outras telas.
- Estados compartilhados e primeiro cadastro podem rolar em altura baixa.
- Seleção de moeda, rotas, serviços, data source, domínio, autenticação e
  sincronização permanecem preservados; nenhum gráfico/insight foi criado.

Oito testes novos cobrem ordem inicial e rota real da ação, geometria e
semântica da privacidade em três tamanhos/escalas, valores positivos/negativos
extensos em 320px/2×, nomes completos, empilhamento desktop ampliado e cadastro
inicial em janela de 360px de altura. Quatro novos goldens ampliam a matriz
para 320/390/800/1200/1440/1920px, claro/escuro, 1,3× e 2×. Os cinco goldens
anteriores da Visão geral foram atualizados; os demais preservam a aparência.

Detector de layout antes/depois: lista vazia. Revisão independente: **PASS**,
sem achados materiais nos sete arquivos de produção e nove renders examinados.
Resultado final: **327 testes passaram**, com análise estática sem problemas.
São renders Flutter e entradas simuladas, sem novo aceite físico Android/iOS,
teclado/leitor de tela ou pacote APK/ZIP. As limitações de aceite da V1 não
foram transformadas em aprovações por esta alteração visual.

## Extensão de movimento — integrada ao plano existente

Pedido adicional do usuário por imagens, sem descartar as fases anteriores.
O adendo na seção 22 do plano e [pollar-motion.md](pollar-motion.md) registram
a autorização para rolagem visual do saldo e celebração breve de meta.

- Saldo confirmado da Visão geral rola entre estados reais e continua montado
  durante recálculo. Moeda, quebra de linha, privacidade e movimento reduzido
  têm fallback imediato; a semântica mantém somente o valor atual.
- Cartões ativos recebem tilt limitado e botão para virar/voltar. O verso usa
  termos existentes; o cartão se transforma na fatura real, com shuttle neutro.
- Gráficos mensais existentes desenham/morfam coordenadas reais e permitem
  retargeting; textos/tabelas continuam exatos. Não foi criado novo período.
- Metas preenchem progresso e celebram uma transição persistida para concluída;
  início da tela, erro e privacidade não disparam celebração.
- Navegação mantém IndexedStack e pilhas, com entrada curta, listas coordenadas
  e resposta de pressão. Busca visível agora também sobrevive ao redimensionar.
- O catálogo de movimento é isolado, rotulado e sem autenticação/banco.

Resultado: **343 testes passaram**, análise estática sem problemas, três
goldens de movimento mobile/intermediários e um desktop com mouse; dois goldens
de Contas atualizados pela inclusão do botão de virar. Os demais goldens do
produto continuam iguais. Prévia local em `dist/pollar-motion-preview.gif`,
com 32 quadros Flutter demonstrativos; não contém dados da conta do usuário.

Validação é de widgets, semântica e pintura, não uma medição de FPS ou aceite
físico de Android/iOS/leitor de tela. Não foi gerado novo APK. A fase 4 visual
continua na sequência; este trabalho adiciona movimento e preserva o redesign.

## Fase 4A — Contas e cartões

Implementação da listagem, preservando formulários e regras financeiras:

- Contas comuns e arquivadas passam a linhas `flat` com divisores, nomes
  completos, tipo e moeda. Em largura/texto padrão, valores e ações ficam
  alinhados na mesma linha; texto ampliado e espaço estreito fazem reflow.
- Valores seguem `openingBalance`, com rótulos de saldo/dívida inicial e
  semânticas correspondentes. Não se criou saldo corrente nem total agregado.
- Crédito mantém flip, tilt, verso real e morph/rota de fatura. Limite e ciclo
  empilham conforme o espaço; todos os valores reservam geometria em privacidade.
- Header e grupos seguem a largura disponível após o rail. Apenas com 980px
  disponíveis e escala até 1,3× há duas zonas de leitura.
- Cadastro e confirmação de arquivamento usam altura adaptável optativa para
  não cortar rótulos em 2×. Os demais botões preservam a configuração padrão.
- Apenas arquivadas agora produz “Nenhuma conta ativa”, com restauração
  disponível e sem alegar que nenhuma conta foi cadastrada.

Nove testes novos cobrem acesso à fatura na primeira viewport 390×844, rail
recolhido, cadastro em 2×, privacidade em três dimensões/escalas, restauração,
flip e rota real, nomes/moedas e valores extensos em 320px/2×. Seis novos goldens
ampliam a cobertura para claro/escuro, 320/390/800/1440px, 1,3× e 2×. Os dois
goldens da listagem foram atualizados; formulário e demais telas conservam os
seus goldens. Detector de layout antes/depois: lista vazia.

Resultado final: **358 testes passaram**, com análise estática sem problemas.

Revisão independente: **PASS para Contas/cartões**, sem achados materiais nos
arquivos e quatro renders examinados. Essa revisão foi estática/visual; não
equivale a teste físico, leitor de tela ou medição de FPS. Não há novo APK/ZIP
nesta parte. A fase 4 ainda inclui Transações e Planejamento.

## Fase 4B — Transações

Implementação da listagem e do detalhe, preservando cadastro, persistência e
cancelamento com confirmação e histórico:

- Busca e tipo combinam; contagem informa o resultado e “Limpar busca e filtro”
  restaura ambos. Despesas continua incluindo compras no cartão e Transferências
  inclui pagamentos de fatura; canceladas permanecem consultáveis.
- Chips aparecem com pelo menos 960px disponíveis e texto até 1,3×. Abaixo disso,
  seletor nativo rotulado Tipo conserva as quatro opções, com altura conforme o
  conteúdo. Abaixo de 600px ou acima de 1,3×, busca e seletor empilham.
- Linhas migradas exibem descrição e metadados completos, com dinheiro exato,
  semântica financeira explícita e geometria reservada em privacidade. Grupos
  diários passam a `flat`; divisores, status e reveal com movimento reduzido
  continuam presentes.
- O painel de 360px exige 1020px disponíveis depois do rail e gutters,
  reservando 640px ao ledger e 20px de intervalo. Sem essa largura, usa modal
  raiz. Busca ou tipo que exclui a seleção deixa de apresentar o painel.
- Texto ampliado, largura disponível inferior a 600px ou altura inferior a
  500px colocam controles e lista na mesma rolagem. Chaves estáveis conservam
  texto e foco da busca tanto nessa troca quanto nas composições dos filtros.
- Descrição, estado, valor e campos do painel são roláveis. O modal desktop
  limita seu viewport de conteúdo para conciliar a medição responsiva dos
  valores com o diálogo nativo; a folha compacta mantém seu fluxo natural.
  Privacidade reage enquanto o modal está aberto, sem conservar valores
  acessíveis. Ações da listagem, detalhe e confirmação usam altura adaptável.

Dez testes novos cobrem os tipos contábeis em 390/1440px, busca combinada e
limpeza, painel conforme a largura local, seleção filtrada, privacidade ao vivo
em modais 390/1200px, descrição e dinheiro extensos em 320px/2×, opção longa no
seletor, privacidade no desktop e busca com foco ao mudar largura/altura.
O teste de foco reproduziu a falha na revisão independente e passou com a
correção. Sete novos goldens cobrem 320/390/800/1440px, claro/escuro, 1,3×/2×
e diálogo em notebook 1200px. Três goldens existentes foram atualizados;
formulários e demais telas conservam suas imagens de referência.

Detector de layout antes/depois: lista vazia. Verificação visual em duas
rodadas confirmou hierarquia, grupos, reflow e detalhe nos estados renderizados.
Revisão independente final: **PASS**, após corrigir a perda de foco ao trocar
a disposição interna da busca e do tipo, sem outros achados materiais.
Resultado final: **375 testes passaram**, com análise estática sem problemas.
Validação de widgets e pintura não equivale a teste físico de Android/iOS,
leitor de tela ou medição de FPS. Não foi gerado novo APK/ZIP nesta parte.

## Revisão visual focal — Visão geral

O usuário considerou o impacto visual das fases anteriores discreto e autorizou
antecipar uma revisão mais expressiva do dashboard. Esta parte amplia o plano
existente, sem descartar as fases concluídas ou as próximas telas.

- Uma faixa tonal teal ocupa toda a largura útil da abertura, com saldo
  confirmado em 48/40px por largura disponível do próprio bloco. Projeção e
  dívida de cartão compartilham a faixa, à direita em espaço suficiente e
  abaixo com divisor no compacto/texto ampliado. Continuam valores distintos.
- O gradiente é estático e exclusivo dessa abertura. Seus stops derivam de
  cores existentes, incluindo mistura de 12% no tema escuro. Foreground e
  texto de apoio passam contraste AA em 21 amostras de cada tema. O tema local
  também aplica essas cores à máscara e ao dinheiro, sem mudar outros módulos.
- O resultado mensal passa a uma faixa de apoio abaixo da posição. Duas barras
  comparam as entradas e saídas projetadas já calculadas, na mesma escala
  relativa ao maior valor; números e rótulos exatos ficam sempre disponíveis.
  Não há histórico fictício, nova projeção ou soma entre moedas.
- As barras desenham em 360ms, sem animar os números; valores zero produzem
  barras vazias. Privacidade remove imediatamente as proporções, inclusive
  durante a animação. Movimento reduzido apresenta o estado final sem tween.
- Transações recentes recebem entrada coordenada por identidade, com o limite
  de stagger já existente. O saldo conserva a rolagem entre valores reais e o
  mesmo estado durante recálculo. Ações da abertura usam altura adaptável.

Nove goldens da Visão geral foram atualizados, cobrindo claro/escuro, privacidade,
320/390/800/1200/1440/1920px e texto 1,3×/2×. Cinco testes novos cobrem contraste
no gradiente, proporções reais, interrupção por privacidade, movimento reduzido
e ausência de barras artificiais sem atividade. Os testes existentes continuam
verificando exatidão, separação de moedas, estados, rotas, reflow e geometria.
Detector após as duas inspeções visuais: lista vazia.

Resultado: **380 testes passaram**, análise estática sem problemas e build
Windows Release remoto concluído. O executável atualizado foi aberto e manteve
janela ativa. Revisão independente final: **ship**, sem achados materiais abertos;
o achado de documentação divergente foi resolvido nos guias e no brief. O perfil
de revisão foi substituído por agente fresco com a referência degradada, sem
herdar o histórico de implementação. A documentação recebeu atualização pontual
e preservou o front matter; não foi criado novo sidecar.

As capturas usam dados de teste. Antes/depois locais para conferência ficam em
`dist/redesign-overview/desktop-before.png`, `desktop-after.png`,
`mobile-before.png` e `mobile-after.png`; não contêm dados financeiros do usuário.
Validação física de desempenho, Android/iOS e leitor de tela continua separada.

## Revisão visual focal — Cartões e faturas

A segunda passagem de impacto visual reforça a identidade de crédito sem
substituir o dashboard ou as linhas de contas comuns/arquivadas:

- Frente azul sólida com nome, tipo, moeda, limite cadastrado em 34px e dívida
  inicial separada. Ciclo, “Ver fatura” e “Virar cartão” ficam explícitos no
  rodapé. O verso preserva somente as condições reais; ações empilham conforme
  a largura local e o texto ampliado, sem proporção física fixa de cartão.
- `PollarCreditSurface` compartilha a identidade com a fatura. Claro usa o azul
  informativo existente e escuro usa seu tom suave; foreground e texto de apoio
  são derivados e auditados. Não há bandeira, número bancário fictício ou novo
  gradiente. O tema local cuida de dinheiro, máscara, ícones e foco.
- Tilt e flip existentes permanecem. O botão textual de virar usa o foco da
  face correspondente; teclado restaura o foco na face visível. O morph optativo
  de crédito leva somente azul e ícone, sem valores retidos no voo. Consumidores
  legados do morph conservam seu padrão; movimento reduzido corta a transição.
- Saldo devido e vencimento lideram a fatura na mesma superfície azul. Estado
  e período ficam fora dela; Total, Pago e Limite disponível reconciliam abaixo.
  Pendentes continuam separados de Pago e reservados contra novo pagamento.
- Métricas medem os três valores e suas máscaras contra a largura local antes
  de escolher colunas. Se não couberem inteiros, ou com texto acima de 1,3×,
  empilham. O revisor encontrou quebra do número em 320px/1,3×; a correção e uma
  regressão específica confirmam o valor íntegro e a geometria de privacidade.
- Utilização do limite desenha sua geometria em 360ms. Privacidade interrompe
  o preenchimento imediatamente, mantendo somente um trilho fixo sem proporção
  e semântica de valor oculto. Movimento reduzido mostra o estado final sem tween.
- Compras e parcelas futuras ficam em grupos `flat`, com descrições completas e
  valores limitados à largura disponível, com quebra e reserva de geometria.
  Totais, agrupamentos, operações e regras de pagamento não foram alterados.

Resultado final: **403 testes passaram**, com análise estática sem problemas e
build Windows Release remoto concluído.

Dez goldens novos ampliam a cobertura de verso, privacidade, temas e texto
ampliado de contas e faturas; as capturas existentes afetadas foram atualizadas.
Testes novos verificam contraste, flip por teclado, privacidade durante flip,
voo neutro entre rotas reais, redução de movimento, reserva de geometria em
quatro dimensões/escalas, interrupção do desenho, pendentes e valores extensos.

Duas inspeções visuais e detector final sem achados. Revisão independente final:
**ship**, com reflow e persistência resolvidos e sem regressões observadas no
escopo da revisão. Perfil alternativo executado em agente fresco, sem herdar
o histórico de implementação. Documentação atualizada pontualmente, preservando
o front matter e sem criar sidecar novo. Isso não equivale a aceite físico,
leitor de tela ou medição de FPS.

Prévia local com dados de teste: `dist/redesign-credit/accounts-before.png`,
`accounts-after.png`, `statement-before.png` e `statement-after.png`.

## Revisão de continuidade — Navegação e listas

Esta passagem conclui a prioridade de movimento entre dashboard, cartões e
destinos operacionais, sem alterar a composição estática das telas:

- A aba atual entra horizontalmente pela ordem do destino, com 24dp em 240ms
  e `easeOutCubic`; RTL inverte o sentido. O conteúdo mantém opacidade integral
  e fica limitado ao viewport, sem exibir cópia da tela anterior.
- `IndexedStack` e navegadores continuam montados. Abas inativas não recebem
  foco, semântica ou tickers; rascunhos, seleção e subpilhas permanecem. Movimento
  reduzido ou navegação acessível interrompem a entrada no meio sem recriar filhos.
- A barra inferior nativa usa 240ms, ou zero em movimento reduzido. Rail, cinco
  destinos, atalhos, recolhimento e comportamento de tocar a aba ativa permanecem.
- Dados/backup, sincronização e preferências passam pelo mesmo `pollarMotionPage`
  já utilizado nos outros detalhes. iOS/macOS conservam `MaterialPage` para a
  navegação do sistema; a fábrica reduzida retorna durações zero. Não se alteram
  mapa de rotas, autenticação, identificação local ou regras de sincronização.
- Linhas de Mais entram com o stagger limitado já existente e não repetem a
  entrada por tema/privacidade. O ledger lembra somente IDs já construídos;
  itens conhecidos não reanimam ao voltar de um filtro ou de outra composição.
- No desktop, `findItemIndexCallback` mantém o estado das linhas sobreviventes
  quando mudam de índice. Chaves por dia estabilizam os grupos compactos, e uma
  chave de PageStorage identifica a rolagem do ledger. Isso não implementa saída
  animada ou interpolação contínua da posição das linhas.
- O painel revela a seleção atual com o efeito existente, sem reter o filho
  anterior. Privacidade durante a entrada remove os valores imediatamente.

Foram acrescentados sete testes de branch, quatro de rotas/fábrica nativa,
três de ledger e quatro goldens de movimento. Cobrem direção/RTL, trocas rápidas,
rascunhos e identidade de estado, isolamento de foco/semântica, redução no meio
do efeito, atualizações comuns, rotas reais e retorno, estado após filtro,
ausência de replay e privacidade na seleção. Capturas de 320/390/1440px incluem
dois temas, texto 2× e movimento reduzido; o instante de 40ms é contado após a
montagem do destino pelo redirecionamento assíncrono.

Resultado: **421 testes passaram** e análise estática sem problemas. A seguir,
as quatro capturas temporizadas foram confirmadas em execução focada, sem mudar
código de produção. Duas inspeções visuais e detector final sem achados.
Build Windows Release remoto concluído e executável aberto com janela ativa.
Revisão independente final: **ship**, sem achados materiais. O perfil alternativo
foi executado em agente fresco; documentação atualizada pontualmente, com front
matter preservado e sem criar sidecar novo.
Essas checagens não são medição de FPS, sessão de leitor de tela ou validação
de gesto de retorno em hardware Android/iOS.

## Sequência restante

Dashboard, cartões/faturas e continuidade de navegação/listas receberam as
passagens priorizadas. A sequência retoma agora as telas pendentes do plano.

4C. Planejamento: hierarquia e reflow de agenda/compromissos, preservando regras.
5. Análises/patrimônio: perguntas, critérios, valores e alternativas textuais.
6. Inteligência: fase condicional de produto, **não incluída** no redesign
   visual sem definição de dados e regras.
7. Refinamento mobile, complementando a validação feita em cada fase.
8. Polimento e acessibilidade transversal.

Esta fase não declara o redesign completo nem transforma as pendências de
aceite da V1 em resultados aprovados.
