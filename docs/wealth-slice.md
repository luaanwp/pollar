# Slice de patrimônio

Este slice reúne metas, ativos, dívidas e patrimônio líquido sem transformar
avaliações manuais em fatos do livro-caixa.

## Limites modulares

- `features/wealth/domain` contém entidades, snapshots e o contrato do
  repositório.
- `features/wealth/application` calcula totais e progresso por contratos
  neutros, sem importar contas ou transações.
- `features/wealth/data` oferece persistência Drift e uma implementação em
  memória para testes.
- `app/data/wealth_ledger_data_source.dart` é o único adaptador que traduz os
  saldos confirmados das contas para o vocabulário patrimonial.
- A rota vive sob `Mais`, que preserva o limite nativo de cinco destinos no
  mobile e pode receber as próximas capacidades sem alterar a shell.

## Regras entregues

- Valores usam unidades menores inteiras e nunca misturam moedas.
- Patrimônio líquido é a soma de saldos confirmados positivos e ativos manuais,
  menos saldos confirmados negativos e dívidas manuais ativas.
- Ativos manuais exigem valor conhecido e data de avaliação; não há cotação ou
  atualização automática implícita.
- Dívidas preservam valor original, saldo devedor, taxa anual em basis points,
  vencimento opcional e data de atualização.
- Metas guardam alvo e valor reservado sem movimentar contas. Progresso e valor
  restante são derivados, e existe no máximo uma meta prioritária por moeda.
- Pausar um registro o remove dos totais ou metas visíveis sem apagar sua
  configuração; a área de gerenciamento permite retomá-lo.
- Atualizações preservam identidade e histórico do registro. Metas podem ser
  concluídas igualando o reservado ao alvo, e dívidas podem ser liquidadas com
  saldo zero e nova data de atualização, sempre após confirmação explícita.
- Formulários bloqueiam descarte e envio duplicado enquanto salvam e preservam
  os campos após falha.

## Persistência

O schema local passa para a versão 5 com tabelas próprias para metas, ativos e
dívidas. A migração v4→v5 preserva contas, transações e planejamento e cria as
novas tabelas vazias.

## Escopo posterior

Cotações de mercado, histórico de avaliações, amortização, garantias, metas
compartilhadas e vínculo automático entre pagamentos e dívidas ficam atrás dos
contratos atuais para uma evolução posterior.

O próximo slice recomendado é análises e relatórios: comparações mensais,
evolução patrimonial, categorias e exportação verificável.
