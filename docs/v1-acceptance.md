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
  novamente “Dados em dia”, 0 pendentes.
- Em consulta `SELECT` no SQL Editor do projeto hospedado, o usuário obteve uma
  linha para `Teste sync V1`: saldo inicial de 0 centavos, conta ativa, despesa
  `oi` de 1 centavo com estado `cancelado`, versão 2 e linha preservada no
  histórico. Isso confirma o estado remoto independentemente do SQLite local.
- Após recompilar e reabrir o app com o Supabase remoto, o usuário confirmou
  que a conta e a despesa cancelada continuam visíveis no mesmo perfil Windows.
  Isso confirma persistência local, não restauração remota em dispositivo novo.
- Em 2026-10-05, o usuário instalou o APK Android em um celular, sincronizou e
  confirmou que `Teste sync V1` foi restaurada com saldo R$ 0,00 e que a despesa
  de R$ 0,01 aparece como **Cancelada**. Isso valida a restauração desses dois
  registros em um segundo dispositivo, além da leitura direta no SQL Editor.
- `flutter analyze` passou e os 264 testes Flutter passaram após a correção do
  saldo inicial vazio para R$ 0,00.
- Os 31 testes pgTAP locais passaram, inclusive isolamento de contas e
  lançamentos entre dois usuários com os mesmos IDs locais.
- As quatro migrações do projeto remoto estão aplicadas; o teste pgTAP usa as
  mesmas funções e políticas, mas não substitui a checagem hospedada.

## Ainda não confirmado

1. Fechar e reabrir o app Android e confirmar que os registros restaurados
   continuam visíveis, com a despesa cancelada e sem pendências de sincronização.
2. Usar uma segunda conta de e-mail em outro perfil/dispositivo para verificar
   que as RPCs remotas não mostram dados da primeira. Não entrar com outra
   identidade no mesmo perfil local: o Pollar bloqueia essa troca para proteger
   o ledger existente. O SQL Editor usa privilégios administrativos e não testa
   as políticas RLS do usuário; os testes pgTAP cobrem esse isolamento localmente.
   Em 2026-10-06, o usuário relatou que saiu da primeira conta no mesmo APK
   Android, entrou com outro e-mail sem limpar/reinstalar, sincronizou com
   0 pendentes e viu telas normais sem os registros `Teste sync V1`/`oi`.
   A tela de proteção esperada não apareceu. A identidade exibida na tela de
   sincronização e a origem dos outros dados ainda precisam ser confirmadas;
   **não considerar o isolamento hospedado aprovado** com esse relato.

Antes de distribuição ampla, ampliar a validação Android, testar iOS em
dispositivo real e configurar SMTP próprio para a entrega de e-mail em
produção. Open Finance fica fora da V1, conforme `PRODUCT.md`.
