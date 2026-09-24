# Slice de dados e backup

Este slice protege o livro-caixa local com um backup completo, verificável e
restaurável sem introduzir dependência de nuvem ou acoplamento entre features.

## Arquitetura

- `features/data_management` define o documento, a validação, os contratos de
  dados/arquivo e o fluxo de apresentação.
- `app/data/local_backup_data_source.dart` é o adaptador de composição autorizado
  a reunir as sete tabelas Drift sem expô-las às regras da feature.
- O gateway local usa o seletor nativo do sistema e salva preferencialmente em
  Downloads, com fallback para os documentos do aplicativo.
- Após restauração, o sinal compartilhado de revisão financeira invalida todas
  as projeções derivadas.

## Formato e integridade

O arquivo JSON declara formato, versão, schema do banco, instante UTC de criação
e as tabelas de contas, lançamentos, orçamentos, recorrências, metas, ativos e
dívidas. As linhas são ordenadas por identificador e o envelope canônico recebe
um checksum SHA-256.

Antes de exibir a confirmação, o aplicativo valida estrutura, versão, checksum,
tipos de todos os campos, IDs repetidos e referências de contas. O arquivo é
texto legível, não criptografado; a tela comunica essa propriedade antes das
ações. A leitura é incremental e recusa arquivos acima de 25 MB antes de
mantê-los integralmente em memória.

## Restauração segura

A confirmação apresenta nome, data, schema, contagens exatas e verificação do
checksum. A substituição ocorre em uma única transação SQLite: filhos são
removidos antes das contas e reinseridos depois delas. Qualquer falha desfaz a
transação e preserva o estado anterior.

## Verificação

Há testes para determinismo, adulteração, incompatibilidade, referências
inválidas, IDs repetidos, round-trip no SQLite, confirmação destrutiva e texto a
200%. Goldens cobrem layouts compacto, amplo, escala de texto e a prévia de
restauração.

## Continuidade

Autenticação e sincronização remota foram implementadas no slice seguinte; o
protocolo e as garantias estão em `docs/identity-sync-slice.md`.
