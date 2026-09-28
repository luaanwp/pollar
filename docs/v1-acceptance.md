# Aceite da V1

Este registro separa verificações automáticas de validações no projeto Supabase
hospedado. Não use dados bancários reais nem apague o SQLite local para testar
sincronização; faça um backup antes de qualquer teste de restauração.

## Confirmado

- O app Windows compilou e abriu com o Supabase remoto em 2026-09-28.
- O usuário confirmou o fluxo de código por e-mail, cadastro/verificação TOTP e
  desbloqueio com Windows Hello no Windows.
- O usuário criou `Teste sync V1` com saldo inicial zero no app conectado ao
  projeto hospedado; a tela informou “Dados em dia / Sincronização concluída”.
  Após fechar e reabrir no mesmo perfil Windows, a conta continuou visível.
  Isso confirma o fluxo observado no app e a persistência local, mas não é uma
  leitura independente da linha no servidor.
- Após a reabertura, o usuário confirmou 0 pendentes e uma segunda
  sincronização sem erro. Nenhuma duplicação foi relatada.
- O usuário criou uma despesa de teste de R$ 0,01 na conta `Teste sync V1` e
  confirmou “Dados em dia”, 0 pendentes após sincronizar. Depois cancelou a
  despesa, confirmou que ela permaneceu no histórico como cancelada e obteve
  novamente “Dados em dia”, 0 pendentes. Ainda não houve leitura independente
  das linhas remotas.
- Após recompilar e reabrir o app com o Supabase remoto, o usuário confirmou
  que a conta e a despesa cancelada continuam visíveis no mesmo perfil Windows.
  Isso confirma persistência local, não restauração remota em dispositivo novo.
- `flutter analyze` passou e os 264 testes Flutter passaram após a correção do
  saldo inicial vazio para R$ 0,00.
- Os 31 testes pgTAP locais passaram, inclusive isolamento de contas e
  lançamentos entre dois usuários com os mesmos IDs locais.
- As quatro migrações do projeto remoto estão aplicadas; o teste pgTAP usa as
  mesmas funções e políticas, mas não substitui a checagem hospedada.

## Ainda não confirmado no ambiente hospedado

1. Ler as linhas da conta e da despesa cancelada no ambiente hospedado com
   credenciais próprias ou restaurá-las em outro dispositivo; a UI já confirmou
   envio e 0 pendentes, mas ainda não houve verificação independente do estado
   remoto.
2. Usar uma segunda conta de e-mail em outro perfil/dispositivo para verificar
   que as RPCs remotas não mostram dados da primeira. Não entrar com outra
   identidade no mesmo perfil local: o Pollar bloqueia essa troca para proteger
   o ledger existente.

Antes de distribuição ampla, validar Android/iOS em dispositivos reais e
configurar SMTP próprio para a entrega de e-mail em produção. Open Finance fica
fora da V1, conforme `PRODUCT.md`.
