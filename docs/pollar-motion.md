# Movimento Pollar — extensão do redesign

Solicitação do usuário: integrar as quatro referências de movimento ao plano
atual, **sem descartar o redesign existente**. As fases 1–3, tipografia, paleta,
hierarquia, dados e rotas continuam. Este adendo substitui a proibição anterior
de animar dígitos e autoriza uma celebração pontual de meta concluída.

## Tese e orçamento

O momento focal é a continuidade entre uma posição financeira real e sua
explicação: o saldo muda para outro valor real, o cartão abre sua fatura e os
gráficos se transformam quando a série muda. Pressão e seleção têm resposta
curta; listas coordenam a chegada dos primeiros itens sem atrasar ações.

`PollarMotion` define feedback de 140ms, mudança de 240ms, momento focal de
360ms e celebração de 700ms. Stagger soma até cinco passos de 20ms, total
máximo de 340ms. Pressão usa escala 0,98 com hit testing original; tilt é
limitado a 0,035 radianos. Não há loops, sensores, áudio ou espera por animação
em uma operação de persistência. Gráficos e faces dos cartões usam limites de
repintura. O código usa o Flutter instalado, sem nova dependência de runtime.

## Implementado nos fluxos reais

| Referência | Aplicação no Pollar |
| --- | --- |
| Animated Balance | Confirmado da Visão geral opta por `PrivacyAmount.animateChanges`. Dígitos do mesmo comprimento rolam individualmente entre caracteres anterior/atual; mudança de comprimento usa troca vertical do texto. Se houver quebra de linha, o valor exato aparece diretamente. Não é um contador aritmético. |
| Shared Element Morph | Cartão de crédito se transforma no espaço da fatura existente ao abrir/voltar. Os dois extremos optam por `creditIdentity: true`: o shuttle intermediário contém somente azul sólido e ícone de primeiro plano, sem cópia de saldos que possa sobreviver à privacidade. O padrão menta da biblioteca e do catálogo permanece; movimento reduzido remove o `Hero`. |
| Interactive 3D Cards | Cartões ativos inclinam com mouse/toque, sem capturar a rolagem. Ações textuais explícitas viram a face; o verso mostra dívida inicial, limite e ciclo já cadastrados. A face oculta não recebe foco, toque ou semântica; os `FocusNode` existentes passam pelo `PollarButton.focusNode` optativo e restauram o foco à ação visível. |
| Limite utilizado da fatura | O preenchimento anima somente geometria por 360ms (`PollarMotion.focal`). Privacidade remove imediatamente a proporção, inclusive durante a transição, preserva trilho neutro de tamanho fixo e anuncia limite oculto. Movimento reduzido pinta a proporção final sem `Tween`. Valores e percentual semântico permanecem atuais, sem quantias intermediárias. |
| Planejamento: disponível e uso do orçamento | “Disponível no orçamento” opta por `PrivacyAmount.animateChanges`, com os estados reais anterior/atual e semântica exata atual. `_BudgetUsage` anima somente a geometria por 360ms (`PollarMotion.focal`, `easeOutCubic`); percentual e estado textuais permanecem atuais. Privacidade descarta imediatamente a animação e a proporção, conserva trilho com preenchimento zero, substitui percentual por “—” e estado relativo por “Uso oculto” neutro, com semântica de uso oculto. Movimento reduzido usa a geometria final estática. |
| Chart Morphing | Gráficos reais de fluxo mensal e saldo desenham a entrada e interpolam coordenadas entre séries/moedas. Uma troca durante o efeito parte da geometria corrente. Valores textuais e semânticos continuam exatos e atuais. |
| Goal Celebration | Progresso da meta prioritária preenche suavemente. Uma meta que passa de incompleta para concluída após atualização bem-sucedida dispara um único acento radial finito, sem bloquear a tela. Não dispara ao abrir dados existentes, em falha de gravação ou em privacidade. |

Botões rotulados têm resposta de pressão. A busca de Transações tem controller
no estado da tela para preservar também o texto visível ao alternar entre
desktop e celular.

Recarregamentos da Visão geral e de Relatórios conservam os dados já exibidos
durante o cálculo, permitindo animar a chegada dos novos resultados. Primeiro
carregamento e erro mantêm seus estados existentes. Não se modifica fonte,
serviço, regra financeira, armazenamento, identidade ou sincronização.

## Análises e patrimônio — fase 5

Relatórios e Patrimônio mantêm uma faixa `financialSurface` sólida por tela,
com resultado/patrimônio líquido de 34px e apoios de 16px; a superfície não
anima. Somente esses totais optam por `PrivacyAmount.animateChanges` e
`PollarRollingAmount`, entre os estados reais anterior e atual. Mantêm a
semântica exata atual e os fallbacks existentes para privacidade, quebra,
moeda e movimento reduzido, sem quantias financeiras intermediárias. Todos os
valores monetários usam largura limitada, quebra e reserva de geometria.

O critério contábil de Relatórios usa `ExpansionTile` nativo. “Base confirmada”
e “Compensados e conciliados” ficam sempre visíveis; a política completa é
expansível. Expansão e rotação do chevron Lucide usam 240ms
(`PollarMotion.change`) e `easeOutCubic`. Movimento reduzido aplica
`AnimationStyle.noAnimation` à expansão e duração zero à rotação. Os gráficos
preservam o morph geométrico existente e as tabelas de valores exatos, incluindo
os seis saldos mensais; privacidade remove imediatamente séries, proporções
e percentuais.

Patrimônio conserva o progresso e a celebração da meta prioritária após
atualização bem-sucedida, sem disparo inicial ou em privacidade. O registro de
metas também oculta percentuais de metas concluídas como “Progresso oculto”;
a taxa anual da dívida vira “taxa oculta”. Datas e estados operacionais
permanecem legíveis. A composição plana, o reflow local e as ações com altura
adaptável não adicionam Rive, cálculos financeiros ou histórico patrimonial.

Capturas `reports_*` e `wealth_*` em `apps/pollar_app/test/goldens/` documentam
compacto/amplo, claro/escuro, privacidade, vazio, conteúdo longo e texto
ampliado. Resultados finais de suíte, análise, build e runtime ficam em
`docs/redesign-progress.md`. O fechamento visual da fase 5 encaminha o redesign
para Mobile (fase 7); Inteligência (fase 6) segue condicional e fora deste slice.

## Navegação e listas

`PollarBranchStack` preserva o `IndexedStack`, os navegadores de cada branch,
buscas e formulários. Somente o destino atual entra horizontalmente, com
deslocamento de até 24dp (`PollarMotion.branchTravel`, `branchTravelDp` no JSON),
240ms e `easeOutCubic`. A ordem dos destinos determina o lado de entrada; RTL
inverte esse lado. O shell recorta o movimento, com opacidade integral e sem
tela anterior duplicada ou snapshot. Branches inativas ficam em `Offstage`,
`ExcludeFocus`, `ExcludeSemantics` e `TickerMode` desabilitado. Movimento
reduzido ou navegação acessível encerram o efeito imediatamente, inclusive no
meio da entrada, sem remontar o conteúdo.

O indicador da barra inferior usa animação nativa de 240ms, ou zero com
movimento reduzido; o rail conserva seu comportamento nativo. Todas as subrotas
de Mais, incluindo Dados e backup, Sincronização e Preferências, usam o
`pollarMotionPage` existente. iOS/macOS conservam `MaterialPage` para o retorno
nativo. Nas demais plataformas, a página customizada usa entrada de 240ms e
retorno de 140ms, com fade e deslocamento de 0,025 da largura; movimento
reduzido remove o efeito. Mapa de rotas e autenticação permanecem iguais.
As cinco linhas de Mais usam `PollarReveal` por identidade, com índices de 0 a
4; reconstruções ordinárias de tema ou privacidade não repetem a entrada.

Transações guarda no `State` somente os IDs das linhas já construídas. Uma
identidade construída pela primeira vez pode entrar com `PollarReveal` e
stagger limitado; filtrar, retornar à branch e alternar entre desktop e compacto
não reanimam IDs já construídos durante a vida desse estado. O conjunto não
retém dados financeiros, widgets de saída ou quadros. No desktop, chaves por
ID e `findItemIndexCallback`, com mapa de IDs para índices, preservam o estado
do reveal quando o filtro muda a posição. A lista possui `PageStorageKey`;
cabeçalhos e grupos compactos têm chaves de data. O padrão implementa entrada
e preservação de estado, sem animação contínua de reordenação ou saída.

O painel contextual usa `PollarReveal` com `identity: selected.id`. O filho e
a privacidade refletem imediatamente a seleção e configuração atuais, sem
`AnimatedSwitcher`, detalhe anterior retido ou cópia financeira de saída.

## Privacidade e acessibilidade

A identidade de crédito usa azul sólido derivado dos papéis existentes:
`creditSurface` é `info` no claro e `infoSoft` no escuro; o primeiro plano é
canvas / texto primário. `PollarCreditSurface` fornece `Theme` local para dinheiro,
máscara, ícones e foco. O limite cadastrado na frente e o saldo devido na fatura
usam 34px. O morph conserva essa identidade sem copiar valores; não introduz
gradiente ou marca bancária, nem substitui a abertura teal 48/40px da Visão geral.

- Somente o `MoneyText` atual fornece semântica do saldo. Quadros anteriores são
  pintura transitória, sem nós acessíveis ou registros financeiros sintéticos.
- Ocultar valores remove imediatamente o animador e os gráficos, incluindo
  quadros anteriores; máscara e reserva de espaço continuam as da fase 3.
- Movimento reduzido, navegação acessível ou branch inativa cortam efeitos
  próprios. Virar o cartão continua disponível sem transição.
- A meta prioritária oculta proporção e percentual em privacidade. A celebração
  é decorativa, ignora ponteiro e não substitui o feedback textual de sucesso.
- Trocas de moeda não rolam dígitos de uma moeda para outra.

## Amostra isolada e limites

O slice 4C de Planejamento conserva sua única faixa `financialSurface` sólida
e os papéis de 34px para disponível e 16px para apoios; não anima a superfície.
Os quatro valores da posição e as regras de mês, moeda, pausa e formulários
permanecem os existentes. Todos os valores monetários usam largura limitada,
quebra e reserva de geometria entre valor e máscara. O disponível adota os
fallbacks já implementados para privacidade, quebra e movimento reduzido;
nenhuma quantia intermediária é calculada.

Testes focados de Planejamento cobrem privacidade durante a transição de uso,
saída estática reduzida e leitura exata, além do reflow e dos fluxos existentes.
Capturas `planning_*` em `apps/pollar_app/test/goldens/` incluem 320/390/640/1200,
claro/escuro, privacidade, valores longos e texto ampliado. Resultados finais de
suíte, análise, build e runtime ficam em `docs/redesign-progress.md`.

`tool/motion_catalog.dart` abre uma amostra explicitamente demonstrativa, sem
perfil, autenticação ou banco. A partir de `apps/pollar_app`:

```powershell
flutter run -d windows -t tool/motion_catalog.dart
```

`test/goldens/motion_golden_test.dart` cobre quadros intermediários no celular,
mouse no desktop e tema escuro com movimento reduzido. A opção de teste
`--dart-define=POLLAR_EXPORT_MOTION=true` exporta 32 quadros em
`build/motion-preview/`; `dist/pollar-motion-preview.gif` é uma prévia local.

Testes verificam interrupções, semântica exata, privacidade, moeda, foco de
teclado, atualização real do provedor financeiro, busca entre branches e meta
com persistência pendente/falha/sucesso. Isso não mede FPS em aparelho físico
nem equivale a um aceite de leitor de tela ou gesto iOS em hardware.

O slice de navegação/listas acrescenta testes de branch, integração das rotas
reais e ledger: direção/RTL, interrupção por movimento reduzido ou navegação
acessível, retenção de estado, filtros, índices e detalhe com privacidade
imediata. `test/goldens/navigation_motion_golden_test.dart` registra os quadros
`navigation_390_light_frame40.png`, `navigation_1440_dark_frame40.png`,
`navigation_390_dark_reduced.png` e `navigation_320_dark_2x_frame40.png`.
Resultados de suíte, análise e build ficam em `docs/redesign-progress.md`.

O refinamento de crédito acrescenta cobertura de contraste em dois temas,
flip por teclado com restauração do foco, privacidade durante o flip, shuttle
neutro na rota real e remoção do `Hero` em movimento reduzido. A fatura cobre
reserva de geometria em três larguras, texto ampliado, pendências e valores
extremos, além de ocultação no meio da animação de limite e saída estática
reduzida. Capturas atuais incluem os versos `accounts_credit_back_390.png` e
`accounts_credit_back_1440_dark.png`, além de `statement_pending_390x844.png`,
`statement_privacy_1200_dark.png`, `statement_390_2x.png` e
`statement_320_130pct.png`, em `apps/pollar_app/test/goldens/`. O resultado final
de suíte, análise e build fica em `docs/redesign-progress.md`.

Contas comuns ainda não têm uma tela própria de detalhe; o morph usa a fatura
real do cartão. Não foram inventados verso com PAN/CVV, investimentos, séries,
seletor de período de Relatórios ou novos destinos. O refinamento visual da
fase 4 registra agora esta etapa de cartões/faturas; as demais etapas e o
polimento transversal seguem seu registro no plano.
