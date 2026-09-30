# Aceite da V1 no Android

Use um APK compilado com `config/supabase.remote.json`. O projeto hospeda apenas
a chave publicável no cliente; nunca inclua chave administrativa no APK.
Execute os passos abaixo com dados de teste e internet disponível. Não limpe os
dados do Pollar no Windows nem no celular para repetir o teste.

O APK de teste foi compilado em 2026-09-30 em
`apps/pollar_app/build/app/outputs/flutter-apk/app-release.apk` (66,8 MB):

```text
SHA-256: A2F68A81F1EBA6463A2080E5160F22A34E2B4CDB98594ECA7A2ED02CB8FFA1FA
```

O pacote exige Android 7.0/API 24 ou mais recente, inclui a permissão
`INTERNET` e passou na verificação de assinatura APK v2. O `build.gradle.kts`
ainda usa a chave de **debug** para assinar a variante release: este APK é
somente para teste interno, não para publicação ou atualização futura na loja.
Nenhum celular estava conectado via ADB durante o build; a instalação e o fluxo
de login ainda não foram exercitados em aparelho físico.

Para instalar, copie **esse arquivo** para o celular por USB, abra-o no app
Arquivos e autorize a instalação desse APK de teste quando o Android solicitar.
Desative depois a permissão de instalar apps desconhecidos para o app Arquivos.
Se optar por ADB com o telefone conectado e depuração USB autorizada, use
`adb install -r apps/pollar_app/build/app/outputs/flutter-apk/app-release.apk`
a partir da raiz do repositório. Não publique este APK nem o envie a terceiros.

## 1. Restaurar a conta existente

1. Instale o APK em um Android onde o Pollar ainda não tenha dados locais.
2. Entre com o **mesmo e-mail** usado no Windows. Digite o código recebido por
   e-mail e depois o código do autenticador já cadastrado. Não cadastre outro
   autenticador se o app oferecer o fator existente.
3. Em **Mais → Sincronização**, toque em **Sincronizar agora** e espere por
   **Dados em dia**, sem erro ou conflito e com **0 pendentes**.
4. Em **Contas**, confira `Teste sync V1` com saldo inicial R$ 0,00. Em
   **Transações**, confira a despesa `oi` de R$ 0,01 como **Cancelada**.
5. Feche e reabra o app; confirme que ambos continuam visíveis. A impressão
   digital/PIN é opcional neste teste e ainda não foi validada em Android real.

Este teste verifica a restauração de **contas e transações**, que são as
entidades sincronizadas na V1. Outros módulos locais não são restaurados pelo
Supabase neste slice.

## 2. Testar isolamento de outra identidade

Use **outro celular** ou uma instalação no **perfil de trabalho/usuário Android
separado**, com armazenamento próprio. Não troque de e-mail na mesma instalação
que restaurou a primeira conta: o Pollar vincula o banco local à identidade
original e bloqueia essa troca.

1. Entre com um **segundo e-mail de teste**, diferente do primeiro, e conclua
   código por e-mail e TOTP.
2. Toque em **Sincronizar agora** e confirme **Dados em dia**, **0 pendentes** e
   ausência de `Teste sync V1` e da despesa `oi`.
3. Para uma prova bidirecional, crie uma conta de teste de saldo zero na segunda
   identidade somente com autorização prévia, sincronize-a e confirme que ela
   não aparece ao sincronizar a primeira identidade.

Um resultado vazio sem sincronização concluída **não** prova isolamento. O SQL
Editor do Supabase usa privilégios administrativos e também não substitui este
teste com duas sessões reais.

## Registro

Anote modelo/versão do Android, resultado de cada etapa e qualquer erro. Não
envie códigos de e-mail, TOTP, chaves de API nem capturas que os mostrem.
