# Pollar V1 — lançada

Em **2026-11-11**, o usuário declarou a **V1 oficialmente lançada**. A entrega
de lançamento é [Pollar 1.0.0+1016](https://github.com/luaanwp/pollar/releases/tag/v1.0.0%2B1016),
do commit `89968ac087ebcc9aadc91839f248f7ce7f64b20a`, com APK Android,
ZIP Windows e `SHA256SUMS.txt` publicados em 2026-11-11 às 19:02:25 UTC.
O [workflow 16](https://github.com/luaanwp/pollar/actions/runs/43080622327)
concluiu com sucesso. A versão inclui as boas-vindas também antes do
desbloqueio de uma sessão salva e os botões Entrar e Cadastrar.

O lançamento encerra o desenvolvimento previsto para a V1. Correções de bugs
podem ser entregues pelo atualizador existente; a evolução de produto passa
ao [roteiro inicial da V1.1](v1.1-roadmap.md). A declaração de lançamento não
transforma os testes sem evidência ou adiados abaixo em testes executados,
nem representa publicação na Google Play ou em outra loja.

## Histórico do fechamento

Em **2026-11-05**, o usuário definiu o encerramento do desenvolvimento da V1
após o ajuste final que mantém Mais nítido com o menu aberto. O escopo inclui
o redesign e as atualizações pelo aplicativo. Open Finance e investimentos
continuam como evolução futura, sem implementação nesta etapa.

O teste físico de atualização Android está descrito no
[passo a passo de aceite](android-v1-acceptance.md). Seu resultado ainda não
foi confirmado. O teste de isolamento remoto entre identidades em instalações
independentes permanece adiado, conforme decisão anterior; o fechamento do
escopo de implementação não o transforma em aprovado.

Os builds atuais são publicados automaticamente em GitHub Releases. O ajuste
final de Mais foi entregue na [release 1.0.0+1014](https://github.com/luaanwp/pollar/releases/tag/v1.0.0%2B1014),
após a execução 42079965541 concluir análise, 585 testes gerais, três testes
de processo, verificações nativas e builds Windows/Android com sucesso.
A execução anterior falhou antes de publicar 1013; o teste Android deve usar
1014 ou uma versão posterior. A atualização continua disponível pelo aplicativo.

## Complemento — tela de boas-vindas

A abertura do Pollar com autenticação configurada sempre mostra as boas-vindas,
inclusive para quem já tem sessão salva aguardando biometria. A composição escolhida pelo usuário foi a B: três faixas convergem
para o monograma P, com texto e botão de entrada disponíveis desde o início.
A animação termina em 800ms e respeita movimento reduzido.

A tela se adapta ao celular e ao computador, nos temas claro e escuro, com
rolagem quando há pouco espaço ou texto ampliado. Os botões são **Entrar** e **Cadastrar**. Entrar leva ao login ou ao desbloqueio
da sessão salva, mantendo renovação por e-mail, autenticador, Windows Hello e
proteção de identidade. Cadastrar abre o e-mail em branco; abrir o formulário
ou usar Voltar preserva a sessão anterior. Só confirmar o novo e-mail pode
trocar a identidade, exigindo o autenticador.

Este complemento foi publicado no build de lançamento `1.0.0+1016` pelo mesmo
fluxo de atualização. Não altera dados financeiros nem inclui conexão bancária
ou investimentos.

Validação local da primeira entrega do complemento: análise estática sem problemas, 600 testes
gerais e três testes nativos de atualização Windows aprovados. A revisão visual
independente retornou **ship**, sem achados materiais. Os renders Flutter
cobrem telefone e desktop nos dois temas, além de um quadro intermediário da
animação. Isso não substitui a conferência em Android físico.
O executável Windows release `1.0.0+1015` também foi compilado localmente com
a configuração remota, e essa primeira entrega foi publicada antes da revisão.

Na revisão de abertura para sessões salvas e de cadastro separado, passaram
605 testes gerais e a análise estática. A revisão visual independente retornou
**SHIP**, sem achados materiais, incluindo os dois botões e o formulário de
cadastro no celular e no computador. Não houve teste físico de biometria nesta
revisão.
O executável Windows `1.0.0+1016` foi compilado com a configuração remota;
os pacotes de atualização desta revisão foram publicados pelo workflow 16.

## Consolidação histórica — 2026-10-23

Versão do aplicativo: **1.0.0+3**. Consolidação: **2026-10-23**.

O pacote Windows foi aceito manualmente pelo usuário no seu ambiente. No
Android, foram confirmados acesso por e-mail/autenticador, restauração dos
registros de teste, bloqueio de outra identidade e preservação dos dados ao
retornar à conta original. O teste de isolamento remoto em instalações
separadas foi adiado por decisão do usuário; esta não é uma aprovação para
distribuição pública.

## Escopo consolidado

- Contas, cartões e lançamentos com valores em centavos inteiros e histórico
  preservado; faturas, parcelas e pagamentos sem duplicar despesas.
- Visão geral, planejamento, relatórios e patrimônio alimentados pelo
  livro-caixa local; exportação e backup/restauração dos dados locais.
- Login sem senha: código de e-mail e TOTP. Sessão em armazenamento seguro e
  desbloqueio local pelo sistema em dispositivo previamente autenticado.
- Sincronização explícita de **contas e transações** via Supabase, com fila
  local, operações idempotentes, versões e resolução de conflitos.

Planejamento, metas, ativos e dívidas permanecem locais: não são restaurados
pela sincronização da V1. O backup local é um recurso separado e seu arquivo
é legível, não criptografado. Open Finance e conexão bancária ficam fora desta
versão, previstos para a V1.1.

## Correções de fechamento

- Saldo inicial vazio ao cadastrar conta passa a valer R$ 0,00.
- Código de e-mail aceita de 6 a 10 dígitos; TOTP continua com 6 dígitos.
- Confirmação aceita avança explicitamente para o autenticador e não reenvia
  um código já consumido; lembrar o e-mail não bloqueia a transição.
- Logout/troca de identidade invalida o desbloqueio local. Sincronizações
  interrompem seu ciclo se a identidade mudar e descartam respostas tardias.
- Outra identidade no mesmo banco local recebe a tela de proteção antes de
  acessar o livro-caixa. O usuário confirmou esse bloqueio no Android e os
  registros originais antes de sincronizar novamente após retornar à conta.

## Entregáveis e verificações

- Windows: ZIP portátil completo, manifesto de arquivos e SHA-256. O usuário
  considerou validado o checklist de abertura sem terminal, login, Windows
  Hello, persistência e sincronização. Não foi declarada uma instalação limpa
  nem uma verificação em outro computador.
- Android: APK `1.0.0+3` para teste interno, assinado com chave de debug.
- Última execução automatizada em 2026-10-23: análise estática sem problemas,
  274 testes Flutter aprovados e testes do empacotador aprovados. Os 33
  arquivos do manifesto Windows foram conferidos dentro do ZIP por SHA-256.
- Os 31 testes pgTAP locais constam como aprovados no histórico de aceite;
  não foram reexecutados nesta consolidação nem substituem o teste hospedado.

Artefatos, hashes e instruções de atualização:
[Windows](windows-distribution.md) e [Android](android-v1-acceptance.md).
O [registro de aceite](v1-acceptance.md) separa relatos manuais e evidências
automatizadas. Esta consolidação altera apenas documentação, sem novo build,
mudança de versão, tag Git ou publicação de release.

## Pendências mantidas explícitas

- Isolamento remoto entre duas identidades em instalações/perfis independentes:
  **adiado**, não aprovado pelo bloqueio local observado.
- Reabertura do processo Android com conferência dos registros antes de
  sincronizar; a troca de conta validada não substitui essa observação.
- Desbloqueio nativo Android, validação de iOS em aparelho e instalação Windows
  em ambiente limpo ainda não declarados validados.
- Assinatura de distribuição, instalador/lojas e revisão da entrega de e-mail
  em produção são etapas separadas. Desde `1.0.0+10`, há verificação, download
  e instalação confirmada pelo aplicativo via GitHub Releases; veja
  [atualizações pelo Pollar](in-app-updates.md). Isso não declara distribuição
  em lojas nem instalação silenciosa.
