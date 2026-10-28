# Pollar — especificação de redesign da UI/UX

> **Estado: especificação de planejamento e auditoria estática.** Base: commit `2177e4f` de `https://github.com/luaanwp/pollar`, documentos do repositório e duas referências visuais. As capturas de `apps/pollar_app/test/goldens/` foram inspecionadas para observar a interface existente; não executei o aplicativo em um dispositivo. Este arquivo é o único acréscimo planejado, sem alteração de código, rotas ou tokens nesta etapa.

## Precedência e alcance

1. `PRODUCT.md` define produto e estágio pretendido: Flutter adaptativo para Windows, Android e iOS, V1 local-first, precisão financeira e privacidade. **O código já contém sincronização Supabase opcional**, ativada quando `SUPABASE_URL` e `SUPABASE_PUBLISHABLE_KEY` são configurados; portanto, a frase documental “etapa posterior” não descreve integralmente o estado da implementação.
2. `DESIGN.md` registra o sistema visual e as regras operacionais vigentes. Este documento propõe substituir algumas regras visuais, sem revogar invariantes financeiras, acessibilidade ou comportamentos já implementados.
3. `pollar_prompts_finance_app.md` é uma visão mais ampla e anterior. O código confirma parte dela (Supabase opcional e relatórios históricos) e não confirma assistente de IA, alertas inteligentes ou integração bancária. Nada disso deve ser inferido da referência visual.
4. Referências: `db9d91e8-7ab9-4a48-b173-bca045e40627.png` é a composição **desktop** clara com patrimônio, gráfico e agrupamentos; `3f245641-af68-4c06-8c0e-100eb8016f97.png` é a composição **mobile** escura com saldo, ações, cartão e transações. A ordem dos arquivos enviados difere da numeração textual do pedido. Somente princípios de composição são aproveitados; marcas, logos, dados, cores e cartões não são copiados.

### O que não pode ser sacrificado pelo redesign

- Dinheiro em unidades menores inteiras, valores exatos e algarismos tabulares; moeda explícita e sem mistura de totais entre moedas.
- Saldo confirmado distinto do projetado; dívida do cartão distinta do caixa; transferências e pagamentos de fatura sem duplicar receitas ou despesas.
- Privacidade que mascara magnitudes, inclusive gráficos e proporções, sem quebrar o layout; rótulos, contexto e estados continuam compreensíveis.
- Histórico preservado por estados de ciclo de vida, feedback corrigível, acessibilidade com texto ampliado e significado nunca dependente só de cor.
- Funcionalidade existente não pode desaparecer por estética; diferenças de comportamento exigem decisão de produto documentada.

## 1. Diagnóstico da interface atual

**Inventário verificado:** Flutter/Dart com Riverpod, go_router, Drift/SQLite, Material 3 e Supabase configurável (`apps/pollar_app/pubspec.yaml`, `lib/main.dart`). Não há CSS: estilo é `ThemeData`, `PollarColors` como `ThemeExtension`, constantes de dimensões/tipografia e widgets Dart. Inter é empacotada em `assets/fonts/inter/`; Lucide vem de `lucide_icons_flutter`. Gráficos de relatórios são `CustomPainter` em `lib/features/reports/presentation/widgets/report_charts.dart`, sem biblioteca de charts declarada. A navegação está em `lib/app/routing/app_router.dart` e `app_shell.dart`. `PollarCard`, `PollarButton`, campos, modal, badge, estados, máscara e `TransactionTile` ficam em `lib/shared/presentation/`. Tokens estão em `pollar_design_tokens.json` e `lib/app/theme/`.

**Telas implementadas:** visão geral, transações e formulário, contas e formulário, fatura, planejamento, patrimônio, relatórios, Mais, preferências, dados/backup, sincronização, entrada e divergência de identidade. O catálogo de componentes `/design-system` é só debug. A navegação principal tem cinco destinos (Visão geral, Transações, Contas, Planejamento, Mais), e Mais contém Patrimônio, Sincronização, Relatórios, Dados e backup e Preferências.

**O que funciona:** capturas e código mostram saldos confirmado/projetado distinguidos, passivo de cartão separado, valores tabulares, estados explícitos, filtro de moeda, relatórios com base contábil declarada e dados alternativos, privacidade transversal, reflow acima de 1,3× em várias telas e painéis/sheets de detalhe adequados. Esses componentes e cálculos são base para evolução, não candidatos a reconstrução indiscriminada.

**Problemas observados nas capturas:** `overview_1440x900.png` apresenta um header superior com “Visão geral” e outro título “Posição atual”; ambos disputam o início da leitura. O saldo e o resultado mensal estão em caixas vizinhas de peso parecido; listas inferiores também são cards contornados, criando quatro retângulos equivalentes. Em `overview_390x844.png`, a ação “Nova transação” vem antes do saldo, e a primeira viewport termina antes de mostrar posições ou movimentos. Em `accounts_390x900.png`, dois cards altos de contas consomem quase toda a primeira tela; o cartão de crédito começa perto da borda inferior. `planning_390x844.png` empilha quatro números grandes no primeiro card e adia agenda e compromissos. `transactions_390x900.png` usa duas linhas de chips de filtro e há truncamento visível de descrição/metadados. Estes são problemas de priorização e densidade, não de cor.

**Inconsistências e limites concretos:** o rail de 256px é fixado por largura de viewport, sem comando de recolhimento; a marca é um quadrado temporário, comentado como placeholder em `app_shell.dart`. `PollarCard` sempre desenha borda estrutural, inclusive quando funciona apenas como agrupador; telas repetem esse padrão. A busca de transações filtra só descrição e categoria, e os filtros visíveis são tipo; não prometer busca por estabelecimento/tag ou filtros adicionais sem domínio e implementação. Em Contas, os cartões mostram **saldo/dívida inicial**, não saldo calculado atual; a Visão geral apresenta posições calculadas. A interface pode nomear essa diferença com mais clareza, sem trocar o dado.

**Manter:** domínio/serviços, `PrivacyAmount`, `MoneyText`, `TransactionTile` como semântica de linha, controles de formulário e feedback, CustomPainters de relatório enquanto responderem às perguntas atuais, `StatefulShellRoute.indexedStack` que preserva estado de cada aba. **Evoluir:** `PollarCard` para distinguir agrupamento sem caixa de container interativo, header do shell, composição da Visão geral, densidade de Contas e Planejamento, navegação recolhível e filtros no mobile. **Não concluído por inspeção estática:** comportamento em dispositivo real, teclado/leitor de tela, performance, preferência de usuários e existência de duplicações funcionais profundas; validar durante implementação.

## 2. Direção visual

**Conceito: carteira pessoal com leitura editorial.** Financeiro, preciso, pessoal, silencioso, premium e confiável. A interface revela primeiro posição financeira, depois sua explicação e ações relevantes. A inteligência aparece como interpretação verificável dos dados, nunca como decoração ou conversa obrigatória.

- Desktop: superfícies amplas, agrupamentos por alinhamento e tipografia; contorno onde delimita interação ou comparação, não em cada bloco de texto. Usar largura horizontal para uma área dominante e uma área de apoio; uma lista financeira deve ser fácil de varrer verticalmente.
- Mobile: saldo em uma abertura forte, ações de alta frequência próximas do polegar, cartões financeiros com identidade de conta sem simular cartão bancário de terceiros; poucas prioridades por viewport. O dark mode pode criar a imersão da referência sem obrigar todos os usuários ao tema escuro.
- Gráficos grandes somente em superfícies de análise com série histórica real e pergunta explícita. Nenhum gráfico fictício para reproduzir a referência.
- O teal permanece a voz de marca. A composição pode ter mais contraste e escala sem acrescentar uma nova identidade cromática.

## 3. Design tokens

### Valores existentes, preservados

| Papel | Claro | Escuro | Uso |
| --- | --- | --- | --- |
| Marca primária | `#087F6B` | `#5ED3B8` | Ação, seleção, identidade |
| Primária hover | `#066858` | `#80DEC9` | Resposta interativa |
| Seleção suave | `#EAF8F4` | `#153B34` | Seleção com rótulo/ícone |
| Canvas | `#FFFFFF` | `#121A18` | Conteúdo principal |
| Fundo | `#F7F9F8` | `#0C1211` | Shell |
| Superfície alternativa | `#F1F4F3` | `#1A2522` | Agrupamento/hover |
| Borda / forte | `#D8DEDC` / `#B9C3C0` | `#2D3B37` / `#40514C` | Divisão e interação |
| Texto primário | `#13201D` | `#EEF4F2` | Números e títulos |
| Texto secundário | `#52615D` | `#B5C3BF` | Apoio |
| Texto atenuado | `#66736F` | `#8B9B96` | Metadados |
| Positivo | `#0F7444` | `#55CF91` | Receita/estado positivo |
| Negativo | `#C53B3B` | `#FF8585` | Risco/saída conforme semântica |
| Atenção | `#8B5707` | `#F3B85D` | Prazo/alerta |
| Informativo | `#2667C9` | `#80AEFF` | Foco/informação/cartão |

As superfícies suaves semânticas permanecem as do front matter de `DESIGN.md`. **Secondary**, **accent** e **surface elevated** não são cores novas: secondary é papel de ação neutra; accent usa o teal da marca; surface elevated usa canvas com sombra nativa apenas para overlay. Não criar hex adicional por conveniência. O `readme.md` do skill local preserva valores semânticos antigos (`#16834F`, `#A86508`); os valores vigentes são `#0F7444` e `#8B5707` em `DESIGN.md`, `pollar_design_tokens.json` e `pollar_colors.dart`. Corrigir essa divergência antes de reutilizar o kit como autoridade visual.

**Escala vigente:** espaçamento 0/4/8/12/16/20/24/32/40/48/64/80px; raio chip 6, controle 10, card 14, badge 999px. Inter com display 32/700/1,2, headline 26/700/1,25, title 18/600/1,35, body 14/400/1,5, label 13/600/1,35, amount 16/600/1,3, eyebrow 11/600/1,3. Os totais destacados atualmente usam 34/600. Usar `fontFeature: tnum` para todo número comparável.

**Proposta de hierarquia, sem mudança de fonte:** o token atual `PollarTypography.amountHero` é 34/600; usar 34px no mobile (hoje a composição compacta o reduz para 30px) e até 40px no desktop quando houver espaço, com rótulo e moeda explícitos. Título de página 26px, seção 18–22px, linha 14–16px, metadado 12–13px. Criar papéis nomeados em `pollar_typography.dart` e `pollar_design_tokens.json`, validar texto ampliado e locale; não espalhar `fontSize` por telas. O saldo nunca encolhe para caber: faz reflow.

**Profundidade:** fundo e canvas criam separação; divisores em linhas e áreas densas, menos bordas em blocos informativos. Overlay e card interativo em hover podem usar elevação mínima existente. **Exceção proposta à proibição atual de gradiente:** somente superfície de um cartão financeiro focal ou abertura mobile, usando derivações do teal do próprio tema e com contraste testado. Não aplicar gradiente em números, gráficos, listas, fundo da tela ou todos os cards. Se a implementação não puder garantir contraste nos dois temas, usar superfície sólida. Registrar os dois stops como tokens derivados após auditoria, sem atribuir hex arbitrário agora.

**Motion:** a proposta inicial de 150–240ms foi ampliada pelo adendo autorizado de movimento ao final deste plano. Preservar redução de movimento e valores reais; não interpolar uma quantia financeira fictícia.

### Decisões que substituem regras visuais vigentes

| Regra vigente | Decisão proposta | Limite e migração |
| --- | --- | --- |
| `DESIGN.md` proíbe todo gradiente | Permitir **um** gradiente tonal focal de marca em cartão/abertura mobile | Variações do teal Pollar, contraste AA, fallback sólido e token para cada tema; editar `DESIGN.md`, `pollar_design_system.md` e skill de design na fase 1 para remover contradição. |
| Card sempre com borda de 1px | Agrupamento editorial pode ser sem borda | Manter borda para interação, ledger e separação necessária; `PollarCard` atual mantém padrão durante migração. |
| Teal apenas em pequenos sinais | Superfície focal pode ter teal/tonalidade de marca | Uma por viewport, sem repetir em relatórios ou listas; sem transformar positivo/negativo em cor de marca. |
| Saldo hero 34px desktop/30px compacto no código | Saldo de 40px desktop/34px mobile como proposta | Reflow e testes em 390px, 320px e 2× antes de fixar tokens. |
| Rail expande automaticamente em `≥1024px` | Permitir escolha de recolhimento | Preservar cinco destinos, acessibilidade e estado de cada branch. |

As regras de precisão, privacidade e semântica de `DESIGN.md` continuam. A imagem mobile usa muitos tons e logos; essa parte **não** será traduzida. A imagem desktop mostra variação patrimonial e sparklines; não afirmar que essa série existe para cada conta do Pollar.

## 4. Arquitetura da informação

**Mapa atual verificado:** cinco branches em `app_router.dart`: `/overview`, `/transactions`, `/accounts`, `/planning`, `/more`. Subrotas `/transactions/new`, `/accounts/new`, `/accounts/:cardId/statement`, `/more/wealth`, `/more/reports`, `/more/data`, `/more/sync`, `/more/settings`; `/sign-in` e `/account-mismatch` fora do shell. `/settings` redireciona, e `/design-system` existe apenas em debug. O `StatefulShellRoute.indexedStack` preserva estado de cada branch.

**Proposta inicial:** manter os cinco destinos principais na primeira fase, pois todos têm telas reais e o quinto agrega ferramentas menos frequentes. Renomear “Transações” para “Movimentações” somente após verificar consistência de linguagem em telas e testes. “Mais” deve priorizar Relatórios e Patrimônio antes de controles de conta, com agrupamentos “Entenda seus dados” e “Seu aplicativo”; não criar um sexto destino “IA”. Um teste de navegação pode decidir se Relatórios merece substituir Mais como quinto destino no futuro, mas isso exigiria realocar Patrimônio, backup, sync e preferências com acesso claro. A fatura continua subrota de Contas. Configurações e sincronização existente não desaparecem.

Desktop: permitir alternar rail de 256px para 72px por controle explícito, com preferência de sessão e rotas estáveis; tooltip/semântica no estado compacto. O tema e a privacidade permanecem no header, sem inventar perfil enquanto auth é opcional. Mobile: preservar bottom nav de cinco itens, com rótulos. Insights entram na tela de origem. Não há chat ou assistente conversacional no inventário atual.

## 5. Desktop

- Shell com área central máxima atual de 1600px e conteúdo analítico de 1280px como ponto de partida. Em ultrawide, aumentar respiro lateral e usar no máximo duas zonas de leitura; não esticar linhas de texto nem gráfico indefinidamente.
- Navegação lateral discreta: evoluir `_Rail`/`_RailHeader` existentes, de 72/256px, com alternância manual e estado ativo por fundo tonal + rótulo + ícone. Conservar cinco destinos e a branch selecionada no recolhimento. O quadrado temporário da marca não deve ser tratado como logo definitiva.
- Header da tela: título, contexto de período/moeda e uma ação principal, sem repetir controles globais em cada card. Privacidade fica acessível globalmente.
- Visão geral: área dominante de saldo confirmado/projetado, resultado mensal e evidências; posições por conta e movimentações recentes em colunas assimétricas apenas com largura disponível. Lista densa usa divisores; cartões são reservados a grupos distintos, chamadas de ação e resumos.
- Gráficos de Relatórios (`report_charts.dart`) com título em forma de pergunta, período, moeda, critério, valores textuais exatos e estados sem dados; não transportar o gráfico da referência para a home sem série verificável.
- Modais para confirmação/formulário focado; painel contextual para detalhe de transação no desktop expandido, mantendo ledger visível conforme `DESIGN.md`; menu para ações secundárias; tooltip apenas como complemento de rótulo.

## 6. Mobile

- Abertura com saldo confirmado como protagonista, projetado explícito logo abaixo ou em alternância rotulada; resultado mensal em sequência. Controle de privacidade no alcance do cabeçalho. Não apresentar um “saldo total” que mistura moedas ou cartões.
- Ações rápidas: “Nova transação” já leva a `/transactions/new`, cujo tipo determina receita, despesa, transferência ou compra em cartão elegível; manter o destino único na primeira fase, mas trocar a ordem visual para deixar saldo acima da ação. Uma folha de escolha rápida só se demonstrar menos passos no fluxo real, sem duplicar formulário nem rotular uma transferência interna como “Enviar dinheiro”.
- Navegação inferior persistente com texto e ícone; área segura do sistema, alvo mínimo 48dp. Uma seção de análise pode usar detalhe próprio sem transformar a home em carrossel de métricas.
- Cartão financeiro focal mostra nome, tipo, saldo/dívida e contexto; cartão de crédito declara passivo, limite e vencimento se esses campos existirem. Evitar cópia de bandeiras, plástico e logos da referência.
- Transações agrupadas por dia, descrição e valor imediatamente visíveis, estado textual, contexto de conta/categoria; detalhes em bottom sheet raiz. Conteúdo extenso rola e expande; carrossel só para entidades equivalentes, com posição e acesso à lista completa.
- Dark mode usa tokens escuros atuais e não vira uma segunda marca; o tema claro recebe a mesma hierarquia estrutural.

## 7. Responsividade

| Contexto | Proposta de comportamento |
| --- | --- |
| Smartphone `<600px` | Bottom navigation, gutter 16px, listas por dia, ações de largura disponível, detalhe em folha inferior; preservar altura segura da barra. |
| Smartphone grande `<600px` | Mesma IA; pode mostrar mais linhas por viewport, sem mudar regra só por altura. |
| Tablet `600–1023px` | Rail 72px; conteúdo prioritário em uma coluna; detalhes em modal para não comprimir ledger. |
| Notebook `≥1024px` | Rail expandível, painel contextual 360px se ledger conservar valor/estado legíveis; faixas paralelas por largura real. |
| Desktop amplo | Duas áreas de leitura no máximo; controlar largura de tabela e gráfico com os limites do sistema atual. |
| Ultrawide | Respiro e painel contextual; não espalhar cards para ocupar largura disponível. |

O layout reage também ao espaço **disponível do componente**, escala de fonte e conteúdo localizado, não só ao tamanho da janela. Acima de 1,3×, reflow vertical dos pares valor/rótulo e das faixas paralelas já descrito em `DESIGN.md`. Pode condensar metadados redundantes; não pode desaparecer valor, moeda, estado ou ação. Dropdown para filtros secundários, sheet para detalhe em espaço estreito. Não converter uma série de contas em carrossel sem alternativa de lista.

## 8. Home / dashboard

Ordem: **(1) saldo confirmado e projetado**, **(2) resultado deste mês com entradas/saídas**, **(3) contas que compõem a posição**, **(4) movimentos recentes**, **(5) uma atenção contextual apenas quando verificável**, **(6) ação de registro** disponível no cabeçalho ou no alcance do polegar. Patrimônio líquido é distinto do caixa e só entra como ligação ou métrica própria se a composição de ativos/dívidas estiver pronta.

“Para onde foi?” pode ser respondido com ligação para Análises ou pequeno resumo categórico real; não adicionar donut e tendência na home só por estética. Não repetir o mesmo saldo em três cards. Empty state leva ao cadastro da primeira conta. Ausência de transações mantém saldo inicial e explicação. Erro não alega perda de dados.

## 9. Contas e cartões

Agrupar contas, cartões e arquivados por títulos e linhas; total de grupo junto de seus itens quando contabilmente válido. Nome/tipo à esquerda, valor e estado alinhados à direita; instituição apenas se for campo real. Cartões são passivos e têm tratamento informativo secundário, nunca entram no saldo de caixa. Detalhe pode mostrar histórico, limite, fechamento e vencimento apenas se código/dados os sustentarem. Formulários continuam dedicados e com divulgação progressiva. Arquivar/restaurar permanece explícito e reversível.

## 10. Transações

Busca e filtros antes do histórico; filtros frequentes visíveis, demais em painel/sheet. Linha: natureza, descrição, categoria/conta, data, valor assinado, estado textual. Estabelecimento e recorrência aparecem somente se modelados. No desktop, ledger plano com divisores e painel contextual; no mobile, grupos por dia e bottom sheet. Foco, seleção, edição e cancelamento preservam contexto e explicam efeito contábil. Valores nunca truncam; metadados podem quebrar ou condensar. Modo privacidade mantém a geometria e mascara magnitudes.

## 11. Gastos e análise

Cada visualização responde a uma pergunta: fluxo mensal “quanto entrou e saiu em cada mês?”, categorias “onde se concentram as saídas?”, saldos “como variou a posição de contas ativas?”. Gráfico + tabela textual exata com período, moeda e critério. No sistema documentado, relatórios de seis meses usam compensados/conciliados; não misturar previstos nem criar variação com dados inexistentes. Comparação com mês anterior exige dois períodos comparáveis e rótulo de base. Anomalia requer regra verificável e amostra suficiente; sem isso, omitir o componente.

## 12. Insights do Pollar

**Padrão futuro, ainda não implementado.** `Insight` contém: tipo (atenção/oportunidade/previsão/mudança), afirmação curta, período, moeda, critério e dado que a sustenta, ação de “Ver movimentos” ou equivalente, estado de cálculo, identificação de estimativa e opção de dispensar. Um destaque por contexto; avisos críticos têm precedência. Insight de assinatura exige histórico de preço, que não foi identificado como capacidade da UI atual. Projeção explicita premissas e não se chama saldo confirmado. Sem base real, mostrar nenhum insight, não exemplos sintéticos. Ícone e rótulo acompanham tom semântico; não usar ✦ como substituto de acessibilidade. Dispensar não altera dados financeiros.

## 13. Assistente / chat

Não há rota, widget ou dependência de assistente conversacional no código examinado. Fica fora das fases visuais imediatas. Se desenvolvido futuramente, oferecer pergunta rápida ligada ao contexto e opção de aprofundar; ações financeiras exigem revisão dos dados e confirmação do usuário. O chat não ocupa o espaço do saldo nem inventa leitura de extrato ou previsão.

## 14. Componentes

| Família proposta | Papel e variantes | Comportamento |
| --- | --- | --- |
| Button / IconButton | Primary, secondary, ghost, danger; normal, foco, loading, disabled | 48dp no Android; ícone isolado com nome e tooltip; ação de formulário larga no compacto. |
| Input / Search / Select | Rótulo persistente, foco, erro, ajuda, moeda localizada | Filtros viram sheet/dropdown no compacto; erros preservam preenchimento. |
| Tabs / SegmentedControl | Poucas visões mutuamente exclusivas | Texto visível; rolagem com indicação se não couber; não esconder destino. |
| Summary / FinancialCard | Saldo confirmado/projetado; conta/cartão, privacy/empty | Protagonismo tipográfico; gradiente opcional só em cartão focal com contraste validado. |
| AccountRow / TransactionRow | Identidade, contexto, valor, estado, seleção | Linha densa desktop; grupo diário mobile; números alinhados. |
| Insight | Evidência, período, severidade, ação, dispensar | Pode expandir para origem; sem dado, não renderizar. |
| Metric / ChartContainer | Valor exato, critério, série e tabela alternativa | Gráfico só com dados reais e máscara global. |
| EmptyState / Skeleton | Sem dados, erro, aguardando cálculo | Skeleton preserva geometria; CTA específico; sem número fictício. |
| Toast / Modal / BottomSheet / Tooltip | Feedback, confirmação, tarefa, contexto | Modal de edição não fecha durante salvamento; foco retorna ao acionador. |
| Navigation | Bottom, rail recolhido/expandido, seleção | Mesmo mapa mental, destinos implementados apenas. |

Nomes acima são **papéis**, não necessariamente nomes de classes. Reusar `PollarButton`, `PollarCard`, `PollarTextField`, `PollarSelect`, `PollarModal`, `PollarBanner`, `StatusBadge`, `TransactionTile`, `PrivacyAmount`, `PollarLoadingState`/`PollarErrorState` e `EmptyState` existentes. Estender `PollarCard` com papel visual explícito, mantendo o comportamento atual como padrão durante migração; não criar um segundo botão/card genérico paralelo.

## 15. Microinterações

Transição curta para revelar detalhe e mudar período; feedback de salvar/sincronizar com estado textual; expansão de insight preserva posição de leitura. O adendo autorizado permite rolagem visual entre estados reais do saldo e transformação da geometria dos gráficos. Não interpolar quantias financeiras fictícias, tornar movimento indispensável à compreensão ou usar gradiente contínuo. Respeitar `reduce motion` e foco do teclado.

## 16. Estados da interface

Loading explica operação; skeleton (se adicionado) replica blocos reais; vazio fornece próximo passo; erro recuperável mantém dados e ação de tentar de novo; dados incompletos identificam a origem ausente; sucesso confirma objeto e efeito. O código **já tem** `/more/sync` com estados local-only, fila, sincronizando, erro e conflitos, e Supabase opcional. Mostrar o estado real, sem sugerir que nuvem está ativa quando backend não está configurado. Modo privacidade cobre texto, barras, proporções, séries, tooltips e semântica acessível de valores.

## 17. Acessibilidade

WCAG AA para texto/controles nos dois temas e sobre qualquer gradiente proposto; alvo mínimo 48dp no Android; foco visível e ordem de tabulação coerente; rótulo em controles de ícone; leitura de valor com sinal e moeda; status por texto/ícone além de cor; gráficos com tabela alternativa. Testar 1,3× e 2× sem corte de rótulos/valores; largura estreita e textos longos. Máscara acessível anuncia “valor oculto”, sem expor valor original. Nenhum gesto é único caminho para ação.

## 18. Mapeamento das telas atuais

Rotas abaixo foram verificadas em `apps/pollar_app/lib/app/routing/app_router.dart`. Os problemas visuais vêm de capturas golden quando citados; os demais são oportunidades de revisão, não defeitos demonstrados.

| Tela/rota atual | Problema ou limite | Nova abordagem | Componentes/arquivos de tela | Prioridade |
| --- | --- | --- | --- | --- |
| `/overview` | Dois títulos e quatro caixas de peso similar no golden; mobile mostra CTA antes do saldo | Header único; saldo dominante, CTA depois; resultado e listas por alinhamento | `overview_screen.dart`, `widgets/overview_metrics.dart`, `overview_account_positions.dart`, `overview_recent_transactions.dart` | Alta |
| `/transactions` | Chips quebram em duas linhas; texto da linha trunca cedo no golden mobile | Filtros de tipo acessíveis sem ocupar duas faixas; melhorar distribuição da linha mantendo valor/estado | `transactions_screen.dart`, `shared/presentation/transaction_tile.dart` | Alta |
| `/transactions/new` | Formulário dedicado já tem divulgação por tipo | Ajustar hierarquia, campos e ação; preservar validação e saída com rascunho | `transaction_form_screen.dart`, campos compartilhados | Alta |
| `/accounts` | Cards altos repetidos; tela distingue saldo inicial, não posição atual | Linhas/agrupamentos densos, rótulo “Saldo inicial” íntegro; passivo separado | `accounts_screen.dart`, `PollarCard` | Alta |
| `/accounts/new` | Formulário dedicado com cartão único | Manter progressão; diminuir bordas redundantes em grupos | `account_form_screen.dart`, campos compartilhados | Média |
| `/accounts/:cardId/statement` | Fatura já expõe saldo, vencimento, compras e parcelas | Saldo/vencimento protagonistas; compras por dia e futuro íntegro | `card_statement_screen.dart`, `widgets/statement_*`, `future_installments.dart` | Alta |
| `/planning` | Primeira viewport mobile concentra quatro valores grandes e oculta agenda | Posição mais concisa, orçamentos/agenda antecipados sem perder números | `planning_screen.dart`, `planning_forms.dart` | Alta |
| `/more/wealth` | Balanço e meta já rastreáveis; muitas superfícies contornadas | Preservar composição e ciclo manual, melhorar contraste entre dossiê e registro | `wealth_screen.dart`, `wealth_forms.dart` | Média |
| `/more/reports` | Dados e gráficos textuais já existem; cards repetidos | Refinar escala e respiro do gráfico, manter critério, tabela e CSV | `reports_screen.dart`, `widgets/report_charts.dart` | Média |
| `/more` | Cinco cards de destino idênticos | Grupos tipográficos com linhas; preservar todos os destinos | `more_screen.dart` | Média |
| `/more/data` | Backup e restauração exigem contexto de segurança | Manter aviso e prévia, simplificar molduras sem reduzir confirmação | `data_management_screen.dart` | Média |
| `/more/sync` | Estado local/nuvem condicional e conflitos já existem | Status real e fila à vista, hierarquia de conflito preservada | `sync_screen.dart` | Média |
| `/more/settings` | Só tema claro/escuro/sistema, escolha ainda não persistida | Opções compactas com seleção clara, sem prometer configuração inexistente | `settings_screen.dart` | Baixa |
| `/sign-in`, `/account-mismatch` | Entrada depende de backend configurado; identidade local deve ficar clara | Tratar privacidade e divergência com linguagem direta | `sign_in_screen.dart`, `identity_mismatch_screen.dart` | Média |
| `/design-system` (debug) | Catálogo precisa acompanhar novos estados | Atualizar amostras e seus goldens com cada componente migrado | `forms_catalog_screen.dart` | Contínua |

## 19. Arquivos que provavelmente serão alterados

Todos os caminhos são relativos à raiz real do repositório. Esta é uma previsão técnica; cada fase só altera o subconjunto necessário.

| Caminho real | Papel atual → alteração prevista | Fase |
| --- | --- | --- |
| `pollar_design_tokens.json` | Fonte de cores/medidas → papéis de superfície, saldo hero e gradiente focal se aprovado por contraste | 1 |
| `apps/pollar_app/lib/app/theme/pollar_colors.dart` | `ThemeExtension` claro/escuro → expor apenas papéis novos realmente usados | 1 |
| `apps/pollar_app/lib/app/theme/pollar_dimens.dart` | Breakpoints 600/1024/1440, raios/spacing → ajustes de composição e rail | 1–2 |
| `apps/pollar_app/lib/app/theme/pollar_typography.dart` | Inter e valores tabulares → papéis tipográficos de abertura | 1 |
| `apps/pollar_app/lib/app/theme/pollar_theme.dart` | Material 3 e estilos globais → papéis de superfície/elevation sem quebrar formulários | 1 |
| `apps/pollar_app/lib/shared/presentation/pollar_card.dart` | Card sempre contornado → variante estrutural/sem borda explícita; padrão legado intacto até migração | 1, 3–5 |
| `apps/pollar_app/lib/shared/presentation/{pollar_button.dart,pollar_form_controls.dart,pollar_text_field.dart,pollar_modal.dart,transaction_tile.dart,privacy_amount.dart}` | Reuso/ajuste de foco, densidade, reflow e máscara; não recriar abstrações | 1, 3–5 |
| `apps/pollar_app/lib/app/routing/app_shell.dart` | AppBar, rail 72/256 e bottom nav → título único, recolhimento manual, seleção e hierarquia | 2 |
| `apps/pollar_app/lib/app/routing/app_router.dart` | Branches e subrotas → manter caminhos; mudar só se navegação exigir nova estrutura justificada | 2 |
| `apps/pollar_app/lib/features/overview/presentation/overview_screen.dart` e `widgets/overview_*.dart` | Resumo e duas listas → composição protagonista sem alterar `overview_service.dart` | 3 |
| `apps/pollar_app/lib/features/accounts/presentation/{accounts_screen.dart,account_form_screen.dart}` | Cards de conta e cadastro → linhas/grupos, rótulos e formulário | 4 |
| `apps/pollar_app/lib/features/transactions/presentation/{transactions_screen.dart,transaction_form_screen.dart}` | Filtros, ledger, painel e formulário → densidade e hierarquia | 4 |
| `apps/pollar_app/lib/features/statements/presentation/card_statement_screen.dart` e `widgets/*.dart` | Resumo, compras, parcelas → tratamento financeiro focal e lista | 4 |
| `apps/pollar_app/lib/features/reports/presentation/{reports_screen.dart,widgets/report_charts.dart}` | Relatórios e CustomPainters → refinamento visual, mantendo dados e tabela | 5 |
| `apps/pollar_app/lib/features/planning/presentation/{planning_screen.dart,planning_forms.dart}` e `apps/pollar_app/lib/features/wealth/presentation/{wealth_screen.dart,wealth_forms.dart}` | Densidade e reflow de planejamento/patrimônio | 4–5 |
| `apps/pollar_app/lib/features/settings/presentation/{more_screen.dart,settings_screen.dart}` | Grupos e preferências | 2, 8 |
| `apps/pollar_app/lib/features/design_system/presentation/forms_catalog_screen.dart` | Amostras e estados → catálogo atualizado por fase | Todas |
| `apps/pollar_app/test/goldens/*.dart` e imagens correlatas | Testes visuais existentes → revisar goldens por mudança intencional, manter variantes 390/1200/1440 e texto 200% | Todas |
| `DESIGN.md`, `pollar_design_system.md`, `.codex/skills/pollar-design/` | Guias atuais proíbem o gradiente e exigem bordas → alinhar decisões implementadas para evitar instruções conflitantes | 1 e por fase |

`apps/pollar_app/pubspec.yaml` confirma dependências e fonte Inter, mas **não demanda alteração**. Nenhum asset de terceiros será copiado; o placeholder de marca em `app_shell.dart` pode continuar até existir uma marca Pollar aprovada.

## 20. Estratégia de implementação

**Gate 0 concluído para planejamento estático:** commit, rotas, temas, componentes, dependências e capturas existentes inventariados. Antes de codificar, confirmar que o branch de trabalho ainda corresponde ao commit auditado e executar o app para verificar fluxos/teclado em ambiente real.

1. **Foundations:** `pollar_design_tokens.json` → `pollar_colors.dart`/`pollar_typography.dart`/`pollar_theme.dart`; criar papéis de saldo e `PollarCard` sem borda, com legado como default. Definir amostra clara/escura no catálogo, contraste e fallback sólido. Atualizar regras conflitantes em `DESIGN.md` e no guia local. **Critério:** catálogo e componentes antigos mantêm aparência/semântica, novos papéis têm tokens documentados; fundamentos estáticos, com animação optativa posterior conforme o adendo de movimento.
2. **Shell/navegação:** `app_shell.dart` com controle de rail 72/256, título sem duplicação e bottom nav preservada; não alterar mapa de rotas na primeira iteração. **Critério:** cinco destinos, subrotas e estado de cada branch continuam acessíveis por toque/teclado; privacidade/tema seguem globais.
3. **Visão geral:** `overview_screen.dart` + `widgets/overview_*.dart`; saldo acima de CTA no mobile, resumo menos encaixotado e listas com hierarquia diferente. Não tocar cálculo de `overview_service.dart`/data source. **Critério:** confirmado, projetado, resultado, passivo e moeda reconciliam; primeira viewport mobile apresenta saldo e começo do contexto mensal.
4. **Contas, cartões, transações e planejamento:** migrar linhas e agrupamentos, manter operações e confirmação; testar ledger, sheet e painel. No planejamento, compactar a posição mensal e antecipar agenda/orçamentos, preservando os quatro totais e as regras de recorrência.
5. **Análises:** apenas gráficos com dados e critério real; tabela e máscara correspondentes.
6. **Inteligência:** fase de produto **condicional**, fora do redesign puramente visual. Primeiro especificar fonte, cálculo determinístico, persistência de dispensa e estados; só então um insight útil. Não incluir frases de exemplo na UI sem dados.
7. **Mobile:** lapidar composição e alcance; esta fase complementa a validação mobile feita em todas as anteriores, não a adia.
8. **Polimento/acessibilidade:** teclado, leitor de tela, 1,3×/2×, movimento reduzido, contraste, dark mode, estados e regressões.

Cada fase deve entregar capturas claro/escuro desktop/mobile, lista de arquivos reais alterados, comparação de fluxos anteriores/novos e verificação de invariantes financeiros. Atualizar `DESIGN.md` apenas quando uma decisão visual for implementada e validada; manter registro de regras substituídas para evitar instruções contraditórias.

## 21. Critérios de aceite

- [x] Repositório, rotas, temas, componentes, dependências e caminhos reais inventariados no commit `2177e4f`.
- [ ] Paleta Pollar preservada; quaisquer tonalidades derivadas justificadas por contraste e registradas como tokens.
- [ ] Visão geral responde saldo, mês, composição, atenção e ação em sequência clara, sem duplicar métricas.
- [ ] Desktop usa largura sem dispersão; mobile tem composição própria, alvos adequados e navegação acessível.
- [ ] Fluxos existentes continuam alcançáveis; nenhuma alteração contábil escondida em refatoração visual.
- [ ] Confirmado/projetado, caixa/passivo, moedas, parcelas e estados continuam corretos e legíveis.
- [ ] Gráficos e insights têm dados reais, período, moeda, critério e alternativa textual; não aparecem quando faltam evidências.
- [ ] Modo privacidade mascara todas as magnitudes e preserva estrutura e contexto nos dois temas.
- [ ] Contraste AA, foco, teclado, leitor de tela, 48dp e texto ampliado verificados nos componentes centrais.
- [ ] Capturas dos fluxos principais e checagens de regressão documentadas por fase.

## 22. Adendo de movimento autorizado pelo usuário

As referências adicionais de Material 3 Expressive, fluidez Apple, listas
coordenadas e microinterações 3D entram **junto do redesign existente**, sem
substituir as fases 1–3. Elas ampliam a regra inicial de motion e autorizam:

1. Rolagem visual do saldo entre dois valores reais; sem calcular quantias
   intermediárias e com semântica do valor atual durante toda a transição.
2. Transformação do cartão na fatura existente, com retorno preservado.
3. Tilt limitado e flip com botão acessível; verso apenas com dados disponíveis.
4. Desenho e transformação de gráficos sustentados por séries reais.
5. Progresso fluido e celebração breve após uma meta realmente concluída.

Feedback, seleção e listas compartilham o mesmo vocabulário de movimento.
Redução de movimento, privacidade, teclado, rolagem e precisão continuam
obrigatórios. A solicitação não cria novos dados, detalhes bancários, gráficos
ou funcionalidades financeiras. Tokens, implementação e limites de validação
estão em [docs/pollar-motion.md](docs/pollar-motion.md). A fase 4 continua
pendente; esta extensão não descarta nem reinicia o plano visual.

## 23. Revisão focal de impacto visual autorizada

Após as fases 1–3, o adendo de movimento e as partes 4A/4B, o usuário avaliou
que a diferença visual ainda era discreta. A prioridade foi ajustada para uma
passagem mais expressiva pela Visão geral, seguida de cartões/fatura e
continuidade da navegação/listas, somada ao plano existente.

A abertura da Visão geral passa a uma faixa teal de largura inteira, com saldo
48/40px e projeção/passivo em zona de apoio. Um gradiente tonal estático, derivado
da paleta existente, é permitido somente nessa faixa, com contraste AA validado
nos dois temas. Abaixo, entradas e saídas mensais já calculadas ganham comparação
de barras na mesma escala, com valores exatos, remoção das proporções em
privacidade e desenho finito respeitando movimento reduzido. Não se cria série
histórica, insight, nova previsão ou transação para fins de apresentação.

As demais fases e invariantes continuam válidas. A execução e seus limites de
validação são registrados em `docs/redesign-progress.md`; acabamento visual
não equivale a aceite físico ou encerramento das pendências da V1.

A passagem de cartões/faturas compartilha o azul informativo existente em uma
superfície sólida: limite cadastrado e dívida inicial distintos no cartão,
saldo devido e vencimento na fatura, ações textuais de virar/abrir e morph
neutro sem valores. As métricas reconciliam com largura medida, preservando
pendentes separados de Pago. Privacidade remove o preenchimento proporcional
do limite e mantém somente trilho neutro fixo. Não há marca, número bancário
fictício ou gradiente de crédito.

A passagem de navegação/listas acrescenta entrada direcional da aba atual,
preservando navegadores e rascunhos, sem exibir a tela anterior em duplicidade.
As linhas de transações preservam identidade nas mudanças de índice e não
repetem a entrada ao retornar de filtros. Trata-se de continuidade e entrada,
sem nova animação de saída ou interpolação contínua de reordenação. Rotas,
regras financeiras e composição estática permanecem; movimento reduzido e
privacidade continuam imediatos.

O slice 4C aplica essa continuidade ao Planejamento: uma faixa sólida destaca
o disponível no orçamento e reduz os três valores de apoio; agenda vem antes
dos limites no compacto e compartilha a largura quando o container comporta.
Seções planas, nomes completos e valores com quebra substituem as caixas
repetidas. O progresso do orçamento usa geometria finita, com percentual,
estado relativo e proporção removidos imediatamente em privacidade. Mês,
moeda, recorrências, formulários e confirmações mantêm suas regras. Evidências
e limites de validação estão em `docs/redesign-progress.md`; a próxima fase
é Análises/patrimônio.

## Limitações da auditoria

O acesso ao repositório funcionou sem autenticação neste ambiente. A análise é estática e usou goldens existentes, não execução interativa no Windows/Android/iOS. Não há evidência de métricas de uso para reordenar destinos, nem dados/engine de IA para publicar insights. O código não contém CSS ou biblioteca de charts: tema Flutter e `CustomPainter` fazem esse papel. Sincronização opcional já consta do código, embora `PRODUCT.md` a descreva como etapa posterior; a documentação de produto deve esclarecer a diferença entre capacidade implementada e estágio de lançamento. O skill local `pollar-design` aponta a `README.md`, enquanto o checkout contém `readme.md` em minúsculas; isso pode falhar em sistemas sensíveis a maiúsculas. O próprio `readme.md` tem dois tons semânticos divergentes dos tokens atuais. Alinhar o guia quando a fase visual for implementada. Validar qualquer alteração visual no aplicativo e nas capturas golden antes de declarar o redesign concluído.
