# Pacote Windows para teste interno

Este slice gera um ZIP portátil completo, não um instalador nem uma versão
assinada para distribuição pública. Não declara a V1 aprovada: o teste remoto
de isolamento entre duas identidades foi adiado pelo usuário em 2026-10-23.

## Gerar

Na raiz do repositório, em PowerShell:

```powershell
.\build-windows.ps1 -Remote
```

O script usa Flutter do PATH ou a instalação isolada já usada por
`run-pollar.ps1`. Em outra máquina, informe `-FlutterPath C:\caminho\flutter.bat`.
É necessário ter o toolchain Windows/Visual Studio configurado para Flutter.

Por padrão, executa os testes do empacotador, `flutter pub get`, análise e todos
os testes Flutter antes de `flutter build windows --release`. Falha em uma etapa
interrompe o processo antes de empacotar um executável antigo. `-SkipChecks`
é um atalho explícito para desenvolvimento; o manifesto registra que os checks
foram omitidos. Sem `-Remote`, compila deliberadamente em modo local.

## Resultado

`dist/` contém uma pasta, um ZIP e um arquivo `.zip.sha256`, com versão, modo
local/remoto e identificador único no nome. Novas execuções não sobrescrevem
pacotes anteriores. O diretório é ignorado pelo Git.

A pasta inclui o executável, runtime Flutter, plugins, assets, código AOT,
instruções e avisos de terceiros. O manifesto informa versão, modo, resultado
dos checks e tamanho/SHA-256 dos arquivos. O checksum externo cobre o ZIP
inteiro, incluindo o manifesto. Hashes detectam alterações; não substituem
assinatura de um editor confiável.

O empacotador copia somente a árvore de release do build. Recusa links,
artefatos essenciais ausentes e arquivos conhecidos de dados/configuração
local. Não copia o perfil do usuário, não acessa o SQLite do aplicativo e não
inclui `config/supabase.remote.json` como arquivo separado. A configuração
publicável remota é incorporada pelo Flutter; credenciais administrativas
continuam proibidas no cliente.

## Abrir e atualizar

1. Extraia o ZIP inteiro, preservando todos os arquivos e a pasta `data`.
2. Feche a versão anterior do Pollar normalmente.
3. Abra `pollar_app.exe` com dois cliques. Não precisa manter terminal aberto.
4. Entre com a identidade original desse perfil Windows. Não limpe dados nem
   restaure backup para atualizar o executável.

Este slice não muda o identificador do app nem o caminho do banco. O pacote
não fornece atualização automática ou desinstalador. Em outro computador,
ainda é necessário validar dependências nativas e o fluxo de primeiro acesso.

## Verificar somente o empacotador

```powershell
.\tests\windows-package.tests.ps1
```

Os testes usam fixtures em diretório temporário exclusivo, sem abrir o app,
enviar e-mails, acessar Supabase ou ler dados financeiros reais.

## Verificação realizada — 2026-10-23

- Build Windows release `1.0.0+3`, modo remoto, concluído após análise estática
  sem problemas e os 274 testes Flutter aprovados.
- Testes do empacotador aprovados, incluindo leitura do conteúdo do ZIP,
  hashes, preservação da origem e rejeição de pacotes incompletos/dados locais.
- ZIP gerado com 16.609.028 bytes; os 33 arquivos do manifesto foram
  conferidos dentro do ZIP por tamanho e SHA-256, sem arquivos extras além
  do próprio manifesto.
- O agente não iniciou o executável durante o empacotamento. Posteriormente,
  em 2026-10-23, o usuário informou que fez o teste e autorizou considerar
  validado o checklist proposto: abertura sem terminal, login, Windows Hello,
  persistência e sincronização. É aceite manual informado pelo usuário no seu
  ambiente, não teste independente em outra máquina ou instalação limpa.

Artefato local:
`dist/pollar-windows-1.0.0+3-remote-20261023-124037-ff82e798.zip`

```text
SHA-256: 46EA690FEEFB398BDB64CC6AFA41C497B14E4E3E654A282FA382B9F8920BF903
```

As notas da versão candidata estão em [`release-notes-v1.md`](release-notes-v1.md).
