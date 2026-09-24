# Slice de relatórios

Este slice transforma o livro-caixa existente em comparações verificáveis sem
persistir totais derivados nem inventar histórico patrimonial.

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

O próximo slice recomendado é gestão de dados e hardening: importação segura,
backup/restauração, autenticação, sincronização e testes de conflito.
