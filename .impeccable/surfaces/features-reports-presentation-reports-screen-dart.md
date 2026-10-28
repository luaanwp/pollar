---
version: 1
slug: "features-reports-presentation-reports-screen-dart"
primary_target: "apps/pollar_app/lib/features/reports/presentation/reports_screen.dart"
related_targets: ["apps/pollar_app/lib/features/reports/presentation/widgets/report_charts.dart"]
---

# Slice de relatórios

Este slice transforma o livro-caixa existente em comparações verificáveis sem
persistir totais derivados nem inventar histórico patrimonial.

## Fase 5 — composição implementada

O contrato das primeiras seis linhas da tela conserva a trilha de evidências do
livro-caixa sereno, sem nova identidade ou seed. Período e moeda antecedem uma
única faixa `financialSurface` sólida, com Resultado do período em `amountHero`
de 34px e entradas/saídas de apoio em 16px. Envelope `PollarCard`, tokens e
catálogo de fundamentos conservam seus contratos.

- Abaixo de 760px no viewport local ou acima de 1,3× de texto, o resumo precede
  Exportar CSV; no amplo a exportação fica no cabeçalho. O botão usa altura
  adaptável. O resumo divide resultado e apoios apenas com 720px locais e texto
  até 1,3×.
- O critério usa `ExpansionTile` nativo: “Base confirmada” e “Compensados e
  conciliados” permanecem visíveis; a política completa é expansível. Expansão
  e chevron Lucide usam 240ms (`PollarMotion.change`, `easeOutCubic`); movimento
  reduzido usa `AnimationStyle.noAnimation` e rotação com duração zero.
- Fluxo e saldo dividem a linha em 6:4 com pelo menos 880px de conteúdo e texto
  até 1,3×; fora disso, fluxo vem primeiro. Fluxo, saldo e categorias usam grupos
  `Semantics`, espaço e divisores, sem cartões externos.
- Tabela de entradas/saídas e os seis saldos mensais exatos ficam visíveis junto
  aos gráficos. `_MetricPair` empilha abaixo de 520px locais ou acima de 1,3×;
  categorias mostram o nome completo acima de valor e percentual. Dinheiro tem
  largura limitada, quebra e reserva de geometria em privacidade.
- Somente o resultado opta por `PrivacyAmount.animateChanges` e
  `PollarRollingAmount`, com estados reais anterior/atual e fallbacks existentes
  de privacidade, quebra e movimento reduzido. A explicação é genérica,
  inclusive no zero, sem revelar polaridade. Gráficos preservam o morph
  geométrico e as alternativas textuais exatas.

Critérios, seis meses, moedas, cálculos de domínio, CSV e SHA-256 permanecem os
existentes. Privacidade mantém período, moeda, categorias e critério, removendo
valores, percentuais, proporções e séries imediatamente. Não há novo período,
histórico patrimonial, Rive ou cálculo financeiro.

Capturas `reports_*` em `apps/pollar_app/test/goldens/` registram compacto/amplo,
claro/escuro, privacidade, nomes/valores longos e texto ampliado. Evidência final
de suíte, análise, build e runtime fica em `docs/redesign-progress.md`.

## Limites modulares

- `features/reports/domain` contém snapshots mensais, categorias e linhas de
  exportação, sempre separados por moeda.
- `features/reports/application` aplica as regras de consolidação e produz o
  CSV determinístico por contratos neutros.
- `app/data/report_ledger_data_source.dart` é o único adaptador que traduz
  contas e transações para o vocabulário de relatórios.
- `features/reports/data/local_report_exporter.dart` grava o CSV e seu arquivo
  de verificação sem expor sistema de arquivos ao caso de uso.
- A rota vive em `Mais > Relatórios`, preservando os cinco destinos principais
  da navegação mobile.

## Regras entregues

- O período reúne os seis meses até o mês corrente e usa apenas lançamentos
  compensados ou conciliados.
- Receitas e despesas incluem compras de cartão, mas excluem transferências e
  pagamentos de fatura para evitar dupla contagem.
- Valores permanecem em unidades menores inteiras; moedas nunca são somadas.
- O saldo líquido mensal soma os saldos iniciais das contas ativas e todos os
  seus lançamentos confirmados até o fechamento de cada mês.
- A composição das saídas agrupa categorias no período, ordena por valor e
  mantém uma alternativa textual exata para os gráficos.
- Modo privacidade oculta valores, percentuais e marcas proporcionais dos
  gráficos sem remover período, categorias, moeda ou estrutura do relatório.
- O layout usa fluxo e saldo em proporção 6:4 quando há largura e escala de
  texto suficientes; fora disso, preserva a mesma ordem em uma única coluna.

## Exportação verificável

O botão `Exportar CSV` produz um arquivo UTF-8 delimitado por ponto e vírgula,
com metadados de versão, moeda, período e critério contábil. As linhas seguem
ordem determinística por data e identificador e guardam o valor assinado em
unidades menores, evitando ambiguidade de arredondamento ou localização.

Um segundo arquivo `.sha256` contém o digest SHA-256 do CSV. O destino preferido
é a pasta de downloads; plataformas sem esse diretório usam a pasta de
documentos do aplicativo.

## Limites explícitos

O gráfico de saldo mostra somente contas ativas do livro-caixa. Ativos e
dívidas manuais não aparecem como uma série histórica porque o produto ainda
não registra versões de avaliação. O dossiê de patrimônio continua sendo a
fonte da posição patrimonial atual.

A fase 5 de Análises e patrimônio encerra esta migração visual. O próximo foco
do redesign é Mobile (fase 7); Inteligência (fase 6) continua condicional e fora
deste slice. Gestão de dados e hardening conservam seu escopo próprio.
