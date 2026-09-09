# Contas e cartões

Este slice introduz a capacidade `accounts` sem acoplar regras financeiras à
interface ou ao banco local. A feature está dividida em:

- `domain`: `Account`, `CreditCardTerms` e o contrato `AccountRepository`;
- `application`: casos de uso para criar, listar, renomear, arquivar e restaurar;
- `data`: adaptador Drift/SQLite e repositório em memória isolado para testes;
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
controller da feature. A raiz em `main.dart` injeta o adaptador Drift e gerencia
o ciclo de vida do banco, mantendo a escolha de armazenamento fora da interface.

## Persistência local

`DriftAccountRepository` implementa o mesmo `AccountRepository` usado pelos
casos de uso. A tabela armazena valores monetários em unidades menores inteiras,
incluindo moeda e configurações opcionais de cartão. O arquivo `pollar.sqlite`
fica no diretório de suporte da aplicação e as contas demonstrativas entram
somente quando o banco está vazio na primeira abertura. A versão do schema
começa em 1 para que mudanças da V2 sejam feitas por migrações explícitas.

Testes de apresentação continuam usando o adaptador em memória, enquanto os
testes de dados exercitam round-trip de todos os tipos, atualização, seed único
e reabertura real do arquivo SQLite.

## Próxima integração

O slice `transactions` agora consome contas por um catálogo de leitura estreito,
implementado na raiz de composição. A feature de contas continua independente;
detalhes da integração estão em `docs/transactions-slice.md`.
