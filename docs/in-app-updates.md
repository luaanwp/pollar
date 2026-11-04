# Atualizações pelo Pollar

## Uso

O Pollar para Android e Windows consulta a última versão publicada em
`luaanwp/pollar` no GitHub Releases. Ao encontrar uma versão superior, mostra
**Nova versão disponível** com o botão **Atualizar**, sem interromper o uso.
Também há **Verificar atualizações** em Mais → Preferências.

Atualizar baixa e verifica o pacote. Depois, a pessoa escolhe instalar:

- Android: confirma a instalação no sistema. No primeiro uso, pode ser
  necessário permitir que o Pollar instale atualizações; voltar e tocar em
  Instalar atualização retoma o pacote já baixado. Cancelar não remove dados.
- Windows: confirma Atualizar e reiniciar após concluir suas edições. A
  preparação é verificada enquanto o aplicativo permanece aberto; depois o
  banco é fechado, os arquivos do programa são substituídos e o Pollar reabre.

A versão anterior ao recurso exige **uma instalação manual inicial**. Depois,
os próximos pacotes podem ser baixados e instalados pelo próprio aplicativo.
O instalador Android continua exigindo a confirmação nativa; não há instalação
silenciosa. A distribuição é por APK direto, fora da Google Play.

## Publicação automática

`.github/workflows/publish-updates.yml` executa em pushes de código para a
`main`, ou manualmente. Alterações somente de documentação não geram pacote.
O workflow fixa Flutter 3.47.2 e versões dos actions por SHA, executa análise,
testes Flutter e verificações de empacotamento/atualização antes dos builds.
Usa `windows-2022` com Visual Studio 2022: o STL mais recente do Visual Studio
2026 rejeitou a integração de corrotinas do plugin Windows Hello em
`windows-latest`. A fixação preserva o plugin e não desativa erros do compilador.
Checkout 7.0.1 e setup-java 6.1.0 usam Node 24 e permanecem fixados por SHA.
O cache Pub fica em `.pub-cache` no próprio workspace, no mesmo disco do
projeto. O compilador incremental Kotlin não consegue relativizar fontes de
plugins entre C: e D:; o workflow verifica essa condição antes dos testes.
Os builds Windows e Android aparecem em etapas separadas no GitHub.
O runner usa o fuso `E. South America Standard Time`, igual às capturas de
referência aprovadas. A prévia de backup exibe a data local, enquanto nome e
checksum preservam UTC; fixar somente a hora da simulação alteraria esses
outros campos. O fuso é configurado apenas na máquina efêmera do GitHub, sem
alterar o computador do usuário, a conversão real ou a comparação exata das
imagens.

Os dois pacotes recebem a mesma versão do pubspec e número `1000 + run_number`,
superior aos APKs locais anteriores. A release é criada como rascunho e só fica
disponível depois de Windows e Android compilarem e os hashes enviados serem
conferidos com o GitHub. Reruns não substituem uma release já publicada.
Essa conferência consulta a release pelo ID: enquanto é rascunho, o endpoint
REST por tag ainda pode retornar 404 e os links usam um identificador temporário.

Ativos estáveis: `pollar-android.apk`, `pollar-windows.zip`, `SHA256SUMS.txt`.
A publicação é concluída em GitHub Releases; um push ainda em compilação ou
com falha não aparece como versão disponível. O aplicativo verifica ao abrir
e ao retomar, com intervalo de seis horas. A consulta manual ignora o intervalo.

Variáveis do repositório: `POLLAR_SUPABASE_URL`,
`POLLAR_SUPABASE_PUBLISHABLE_KEY`, `POLLAR_ANDROID_CERT_SHA256`.
Segredos: `POLLAR_ANDROID_KEYSTORE_BASE64`, `POLLAR_ANDROID_STORE_PASSWORD`,
`POLLAR_ANDROID_KEY_ALIAS`, `POLLAR_ANDROID_KEY_PASSWORD`.

A chave Android configurada é a mesma dos APKs já instalados, cuja impressão
SHA-256 foi comparada antes da configuração. Não substitua essa chave: uma
assinatura diferente impede atualização sobre a instalação existente. Chave
privada e senhas ficam somente nos segredos do GitHub e no armazenamento local
original; não entram no repositório, nos pacotes ou no aplicativo.

## Verificações e dados

O aplicativo aceita apenas releases publicadas, estáveis e superiores à versão
instalada, com o ativo correto, URL HTTPS do repositório e SHA-256 fornecido pela
API do GitHub. Downloads incompletos, tamanho divergente ou hash incorreto são
descartados. Falhas de consulta ou download não bloqueiam login nem finanças.

O Android verifica nome do pacote, versão superior e assinatura igual à atual
antes de abrir o instalador. O FileProvider expõe somente o diretório de cache
das atualizações, com permissão temporária de leitura.

O atualizador Windows confere o ZIP, limites, caminhos, manifesto, arquivos e
metadados do executável. A identidade interna permanece `com.pollar/pollar_app`.
O script não acessa AppData nem restaura/exclui bancos. Ele guarda cópia dos
arquivos gerenciados antes de substituir e tenta reverter se a instalação
falhar. Arquivos alheios ao pacote permanecem na instalação. Logs de falha e
cópias de recuperação ficam no cache `pollar-updates`, fora do Git.

Os testes incluem seleção segura de releases, rejeição de downgrade, downloads
reais em servidor local, corrupção/truncamento, concorrência, falha offline,
permissão Android e cancelamento da confirmação. Um teste Windows com executáveis
isolados verifica preparação, espera pelo encerramento, substituição, reabertura
e preservação de um banco alheio ao pacote, além de rejeição de hash e caminhos
inválidos. Capturas verificam aviso e ação em 320px/texto 2× e 1200px.

O teste isolado não comprova instalação física no Android nem simula todas as
falhas possíveis de disco/antivírus/permissões. O resultado da primeira execução
remota do workflow e os artefatos publicados são registrados após sua conclusão.

## Verificação inicial — 2026-11-04

A suíte local completa passou com 565 testes antes das três verificações finais
adicionais. Após os ajustes de teclado/altura e recuperação da instalação,
31 testes direcionados passaram e a análise não encontrou problemas. O teste
nativo do atualizador e os testes do empacotador também passaram. A revisão
independente encerrou com **ship**, após corrigir o limite pela altura do body.
Na execução remota 41905502264, os **568 testes** passaram, assim como os testes
do empacotador e a instalação nativa isolada. Essa execução não publicou uma
release: a compilação Windows parou na incompatibilidade do STL descrita acima.
A execução 41920105156 também passou nas verificações e compilou o Windows.
O Android apontou fontes de plugins no cache C: e projeto no D:, corrigido pela
localização do cache no workspace. Não foram desativados testes nem compilação
incremental para contornar essas falhas de ambiente.

Windows e Android locais `1.0.0+10` compilaram. O APK foi inspecionado: pacote
`com.pollar.pollar_app`, código 10 e assinatura igual ao APK 8 instalado. Artefato
local: `dist/pollar-redesign-v1.0.0-10.apk`, SHA-256
`CE9A957E90D8808832E1C6A1A7C496B46FE445675F9C8A5656423DC6F63E3426`.

Na janela nativa do Windows, os dados originais continuaram visíveis e
Preferências mostrou **Versão instalada: 1.0.0+10**, **Pollar atualizado** e a
ação Verificar atualizações, antes de existir a primeira release pública.
O reinício foi ajustado para abrir a janela do Pollar normalmente, mantendo
somente o processo auxiliar oculto.

### Teste do canal real e lançamento do auxiliar

Os pacotes da execução 41922962873 compilaram e foram enviados ao rascunho
1007. A conferência por tag retornou 404; a consulta por ID foi corrigida e
testada nesse mesmo rascunho. Depois de baixar novamente e conferir hashes,
manifesto Windows, versão Android e assinatura, a publicação foi concluída para
o teste do aplicativo.

No Windows, o Pollar encontrou a versão 1007 pelo canal real e baixou o ZIP
com sucesso. O reinício não ocorreu: os modos detached do Dart encerraram o
PowerShell antes do script. O processo normal executou a mesma verificação.
A versão 1007 foi marcada como prévia e a execução 1008 foi cancelada antes
de publicar o mesmo cliente. O programa aberto permaneceu na versão 10.

`WindowsUpdateLauncher` agora mantém o auxiliar oculto em modo normal, drena
saída, registra erro de lançamento e detecta término prematuro. Três testes
Windows reais verificam handshake a partir do Flutter, diagnóstico de falha e
sobrevivência do auxiliar após `exit(0)` do processo Dart pai. Os três passaram.
O bootstrap local seguinte é `1.0.0+11`; o novo teste completo de instalação
será registrado após sua execução.

### Primeira publicação automática concluída

A [execução 41929390417](https://github.com/luaanwp/pollar/actions/runs/41929390417)
terminou com **success** em 2026-11-04: análise sem problemas, **571 testes
Flutter aprovados**, verificações nativas de empacotamento/atualização,
compilações Windows e Android e publicação pelo próprio workflow. Não foi
necessária publicação manual dessa execução.

A [release estável 1.0.0+1009](https://github.com/luaanwp/pollar/releases/tag/v1.0.0%2B1009)
aponta para `03211e4bba74f186ddb196c81b543b5950826649`. A API pública
`releases/latest` confirmou `draft=false` e `prerelease=false`. Os arquivos
foram baixados novamente e seus SHA-256 conferidos contra a API e SHA256SUMS:

| Arquivo | SHA-256 |
| --- | --- |
| pollar-windows.zip | `c3155f5a63a06e2669ddd61f6778dbeba92ae9a8c0ee6e57a5f3b00ec9ad5aaf` |
| pollar-android.apk | `ba85a76d45beb8cbd61a237e61d53a70123405f301fc80bcf74ec0d8d8f4abbc` |

O APK publicado contém `com.pollar.pollar_app`, versão `1.0.0`, código `1009`.
O apksigner confirmou a assinatura original
`ed8cd75d2110080957c0e1cffb40191ab20fa2b9891b159538de76164fe492e4`.
O pacote Windows publicado passou no próprio auxiliar com `-ValidateOnly`,
incluindo manifesto, hashes dos arquivos e identidade do executável.

Na janela local `1.0.0+11`, após o desbloqueio pelo usuário, as quatro
posições e a despesa cancelada continuaram visíveis. Mais → Preferências
mostrou a versão instalada e Verificar atualizações. A instalação dessa
release pelo botão e a confirmação física no Android são verificações
separadas da publicação e da validação dos pacotes.

Referências: [GitHub Releases API](https://docs.github.com/en/rest/releases/releases),
[FileProvider Android](https://developer.android.com/reference/androidx/core/content/FileProvider),
[assinatura Android](https://developer.android.com/studio/publish/app-signing).
