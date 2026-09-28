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
- `flutter analyze` passou e os 261 testes Flutter passaram após a correção do
  roteador de autenticação.
- Os 31 testes pgTAP locais passaram, inclusive isolamento de contas e
  lançamentos entre dois usuários com os mesmos IDs locais.
- As quatro migrações do projeto remoto estão aplicadas; o teste pgTAP usa as
  mesmas funções e políticas, mas não substitui a checagem hospedada.

## Ainda não confirmado no ambiente hospedado

1. Ler a linha da conta no ambiente hospedado com credenciais próprias ou
   restaurá-la em outro dispositivo; a UI já confirmou envio e 0 pendentes,
   mas ainda não houve verificação independente do estado remoto.
2. Com o valor de teste autorizado de R$ 0,01, criar um lançamento nessa
   conta, sincronizar e confirmar o mesmo resultado. Um lançamento de valor
   zero não é aceito pelas regras financeiras. Depois, cancelá-lo e
   sincronizar novamente, preservando o histórico.
3. Após sincronizar um lançamento, fechar e reabrir o Pollar no mesmo perfil
   Windows, desbloquear com TOTP ou Windows Hello e confirmar o lançamento.
   A conta já sobreviveu a esse teste. Isso testa persistência da sessão e do
   SQLite, mas **não** prova restauração remota em dispositivo novo.
4. Usar uma segunda conta de e-mail em outro perfil/dispositivo para verificar
   que as RPCs remotas não mostram dados da primeira. Não entrar com outra
   identidade no mesmo perfil local: o Pollar bloqueia essa troca para proteger
   o ledger existente.

Antes de distribuição ampla, validar Android/iOS em dispositivos reais e
configurar SMTP próprio para a entrega de e-mail em produção. Open Finance fica
fora da V1, conforme `PRODUCT.md`.
