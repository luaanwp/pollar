# Arquitetura modular do Pollar

## Objetivo

A V1 deve poder crescer sem transformar mudanças da V2 em uma reescrita total.
Os módulos são separados pela razão de mudança: regras financeiras, composição
do aplicativo, componentes compartilhados e capacidades de produto.

```text
main
  └─ app (composição, rotas, tema e estado global)
       ├─ features (capacidades independentes)
       │    ├─ presentation
       │    ├─ application   [quando houver casos de uso]
       │    ├─ domain        [quando a regra pertencer à feature]
       │    └─ data          [quando houver persistência/integração]
       ├─ shared (UI e adaptadores reutilizáveis)
       └─ core (valores e invariantes financeiros em Dart puro)
```

## Limites de dependência

- `core` não depende de Flutter, Riverpod, navegação, banco, rede, `app`,
  `shared` ou `features`. Isso permite testar e reutilizar regras financeiras
  fora da interface atual.
- `shared` pode depender de `core` e dos contratos visuais globais em
  `app/theme`, mas nunca de uma feature.
- Cada diretório em `features` representa uma capacidade. Uma feature pode
  depender de `core`, `shared` e serviços globais de `app`; não importa outra
  feature diretamente.
- `app` é a raiz de composição. Ele conecta rotas, providers e features, sem
  receber regras financeiras.
- Infraestrutura futura implementa interfaces definidas pela camada de
  domínio/aplicação que a consome. Drift e Supabase não entram no domínio.

O teste `test/architecture/module_boundaries_test.dart` protege os limites que
podem ser verificados por imports. Exceções arquiteturais devem ser discutidas
e documentadas; não se enfraquece o teste apenas para acomodar um atalho.

## Forma de uma feature

Uma feature começa pequena, normalmente apenas com `presentation`. Pastas
vazias não são criadas antecipadamente. Quando comportamento real surgir:

- `domain`: entidades, value objects e interfaces próprios da capacidade;
- `application`: casos de uso e coordenação de regras;
- `data`: DTOs, tabelas, fontes locais/remotas e implementações de repositório;
- `presentation`: widgets e providers que chamam a camada de aplicação.

APIs públicas entre camadas devem ser estreitas. Widgets não acessam Drift ou
Supabase diretamente. Casos de uso não recebem `BuildContext`.

## Preparação para a V2

A V2 pode trocar telas, navegação, armazenamento ou sincronização preservando
`Money`, regras contábeis e contratos de aplicação. Mudanças incompatíveis em
dados terão migrações versionadas; mudanças de regra financeira terão exemplos
de antes/depois e testes de regressão.

Não se adicionam abstrações sem consumidor real. O ponto de extensão nasce no
primeiro limite concreto — por exemplo, uma interface de repositório quando a
feature precisar alternar entre armazenamento local e remoto. Isso mantém a V1
simples e deixa substituições futuras explícitas.

## Decisões atuais

- `Money` armazena unidades menores inteiras e identifica a moeda.
- Regras de lançamentos e saldos vivem em `core/ledger`.
- Entrada/saída monetária transforma texto somente na borda da apresentação.
- Rotas são compostas centralmente em `app/routing`.
- O catálogo de design é uma feature de desenvolvimento e não persiste dados.
- Preferências em memória são provisórias; a persistência futura será acessada
  por uma interface da feature de configurações.
- Contas e cartões vivem na feature `accounts`; o domínio define o contrato de
  repositório e a implementação em memória pode ser trocada por Drift na raiz
  de composição, sem alterar casos de uso ou apresentação.
