# Contas e cartões

Este slice introduz a capacidade `accounts` sem acoplar regras financeiras à
interface ou ao banco local. A feature está dividida em:

- `domain`: `Account`, `CreditCardTerms` e o contrato `AccountRepository`;
- `application`: casos de uso para criar, listar, renomear, arquivar e restaurar;
- `data`: repositório em memória, substituível pelo adaptador Drift;
- `presentation`: controller Riverpod, lista responsiva e cadastro de contas/cartões.

## Decisões de domínio

- Conta tem identificador estável, nome, tipo, moeda, saldo inicial e estado.
- Cartão de crédito é uma conta de passivo especializada. Compras reduzem seu
  saldo contábil e pagamentos de fatura o aproximam de zero, conforme as regras
  centralizadas em `core/ledger`.
- Um cartão exige limite positivo, dia de fechamento e dia de vencimento entre
  1 e 31. O limite e o saldo inicial usam a mesma moeda da conta.
- Contas comuns não aceitam configuração de cartão.
- Remoção é arquivamento reversível. O identificador permanece disponível para
  transações e histórico; exclusão física não faz parte do contrato.
- Nomes são normalizados nas bordas, mas não precisam ser únicos. Instituições
  e usuários podem legitimamente manter contas com nomes iguais.

## Integração de apresentação

A rota `/accounts` separa contas, cartões e itens arquivados; valores respeitam
o modo privacidade global. `/accounts/new` coleta os dados e chama somente o
controller da feature. A raiz em `main.dart` injeta o repositório temporário,
mantendo a escolha de armazenamento fora da interface.

## Próxima integração

Persistência Drift implementará o mesmo contrato e substituirá a fonte em
memória na raiz de composição, sem alterar domínio, casos de uso ou widgets.
