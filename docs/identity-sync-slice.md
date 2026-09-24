# Slice de identidade e sincronização

Este slice mantém o SQLite como fonte imediata da interface e acrescenta uma
replicação explícita, autenticada e tolerante a repetição para contas e
lançamentos. Sem configuração de backend, toda a experiência anterior continua
local e funcional.

## Fluxo e garantias

- Toda escrita local e sua entrada de outbox acontecem na mesma transação Drift.
- Cada operação recebe um UUID estável; novas tentativas reapresentam esse UUID.
- O servidor registra o resultado em `sync_mutations`, tornando a aplicação
  idempotente e impedindo lançamentos duplicados.
- Cada entidade carrega uma versão remota. Uma base divergente produz conflito,
  preserva as duas versões e exige decisão da pessoa.
- Exclusões são tombstones versionados. O estado de exclusão também é preservado
  no conflito para impedir ressurreição acidental.
- Pull usa cursor monotônico; a UI só lê o banco local e é invalidada depois da
  aplicação atômica das mudanças remotas.
- Falhas mantêm a fila e aplicam backoff exponencial limitado a uma hora.

## Identidade e segurança

E-mail/senha e magic link usam Supabase Auth. A sessão é persistida por
`flutter_secure_storage`, não por preferências comuns. Todas as tabelas remotas
têm RLS habilitada e apenas política de leitura das próprias linhas; mutações
passam pelas RPCs autenticadas, que validam `auth.uid()` e posse de dispositivo,
operação e entidade. `service_role` nunca pertence ao cliente.

Na primeira sincronização, o ledger local é vinculado ao identificador da conta.
Uma sessão diferente no mesmo perfil do sistema é desviada para uma tela de
proteção antes de abrir o shell: o app não mostra nem envia os dados locais até
que a conta original volte. A restauração explícita de um backup reinicia esse
vínculo junto com cursor, versões e conflitos e enfileira o conteúdo restaurado.

## Conflitos

A tela “Sincronização” apresenta contagens exatas e compara campos legíveis das
duas versões; dinheiro usa formato pt-BR, enums são traduzidos e referências de
conta usam nomes em vez de UUIDs. “Manter deste dispositivo” cria uma nova operação baseada na versão
remota observada. “Usar servidor” aplica a versão remota — inclusive tombstone —
e atualiza a versão local. Nenhuma escolha ocorre silenciosamente.

## Operação

O backend é opt-in por `SUPABASE_URL` e `SUPABASE_PUBLISHABLE_KEY` em
`--dart-define`. O diretório `supabase/` contém configuração local, migração,
RLS, RPCs e testes pgTAP. Criar ou vincular projeto remoto permanece uma ação
separada e explicitamente autorizada.

## Verificação

Flutter cobre migração local, outbox, retry, pull e conflitos; goldens cobrem
entrada e sincronização em tamanhos compacto, amplo e texto a 200%. Os testes
SQL usam pgTAP e dependem de Docker/Supabase local disponível.
