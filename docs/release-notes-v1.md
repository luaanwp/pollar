# Pollar V1 — versão candidata para uso interno

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
  em produção são etapas separadas. Não há atualização automática.
