# Aceite da V1

Este registro separa verificações automáticas de validações no projeto Supabase
hospedado. Não use dados bancários reais nem apague o SQLite local para testar
sincronização; faça um backup antes de qualquer teste de restauração.

## Confirmado

- O app Windows compilou e abriu com o Supabase remoto em 2026-09-28.
- O usuário confirmou o fluxo de código por e-mail, cadastro/verificação TOTP e
  desbloqueio com Windows Hello no Windows.
- `flutter analyze` passou e os 261 testes Flutter passaram após a correção do
  roteador de autenticação.
- Os 31 testes pgTAP locais passaram, inclusive isolamento de contas e
  lançamentos entre dois usuários com os mesmos IDs locais.
- As quatro migrações do projeto remoto estão aplicadas; o teste pgTAP usa as
  mesmas funções e políticas, mas não substitui a checagem hospedada.

## Ainda não confirmado no ambiente hospedado

1. Criar uma conta corrente `Teste sync V1` com saldo inicial R$ 0,00 e tocar
   **Mais → Sincronização → Sincronizar agora**. Esperado: fila zerada, horário
   de última sincronização preenchido e nenhuma mensagem de erro.
2. Sincronizar novamente sem alterações. Esperado: nenhuma duplicação e fila
   ainda zerada.
3. Com um valor de teste combinado previamente, criar um lançamento nessa
   conta, sincronizar e confirmar o mesmo resultado. Um lançamento de valor
   zero não é aceito pelas regras financeiras; não criar valor fictício sem
   consentimento explícito.
4. Fechar e reabrir o Pollar no mesmo perfil Windows, desbloquear com TOTP ou
   Windows Hello e confirmar conta e lançamento. Isso testa persistência da
   sessão e do SQLite, mas **não** prova restauração remota em dispositivo novo.
5. Usar uma segunda conta de e-mail em outro perfil/dispositivo para verificar
   que as RPCs remotas não mostram dados da primeira. Não entrar com outra
   identidade no mesmo perfil local: o Pollar bloqueia essa troca para proteger
   o ledger existente.

Antes de distribuição ampla, validar Android/iOS em dispositivos reais e
configurar SMTP próprio para a entrega de e-mail em produção. Open Finance fica
fora da V1, conforme `PRODUCT.md`.
