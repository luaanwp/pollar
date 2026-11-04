# Conferência dos fluxos no Windows — 2026-11-03

## Verificação pela janela nativa

A versão `1.0.0+6` foi inspecionada no Windows do usuário, após ele realizar o
login e disponibilizar a janela. As ações foram conferidas visualmente na
janela Pollar, de 1600×900px, sem salvar registros financeiros.

| Fluxo | Observação confirmada |
| --- | --- |
| Abertura | Janela responsiva, título e ícone Pollar, entrada centralizada. |
| Navegação | Visão geral, Transações, Contas, Planejamento e Mais abrem. |
| Contas | Lista vazia, cadastro com saldo inicial R$ 0,00 e retorno à lista. |
| Transações | Busca, filtros e estado sem lançamentos aparecem. |
| Visão geral | Orientação para cadastrar a primeira conta. |
| Planejamento | Novembro de 2026; orçamento abre com campos e permite cancelar. |
| Relatórios | Estado sem dados explica o requisito de conta e lançamentos. |
| Sincronização | Tela abriu com 0 pendentes e primeira sincronização ainda não realizada. |

Esses estados vazios não validam cálculos, gravação ou faturas com dados. O
login foi realizado pelo usuário; os códigos não foram coletados pelo agente.

## Falhas encontradas e corrigidas

- Os cinco destinos de Mais não ofereciam volta visível. O cabeçalho agora tem
  `Voltar para Mais`, com retorno pela pilha e alternativa à raiz da seção.
- Novo compromisso ficava silenciosamente desabilitado sem uma conta ativa.
  Agora responde com uma orientação e acesso a Contas; com conta ativa, abre
  diretamente o formulário. A criação da agenda usa o mesmo fluxo.
- A alteração de `ProductName` para Pollar no recurso Windows mudou a pasta
  calculada por `path_provider`. `CompanyName` e `ProductName` determinam a
  pasta de suporte, conforme `path_provider_windows` 2.3.0. Uma leitura SQLite
  somente para consulta confirmou 4 contas e 1 lançamento em
  `%APPDATA%/com.pollar/pollar_app`, enquanto `%APPDATA%/com.pollar/Pollar`
  tinha 0 contas e 0 lançamentos. Nenhum arquivo foi removido ou movido.

A identificação interna volta a `com.pollar/pollar_app`; o nome visível continua
Pollar. O empacotamento passa a conferir esses metadados no executável compilado
e recusa identidades diferentes. Os testes do empacotador reproduzem a troca de
nome do produto e também rejeitam a troca do nome da empresa.

## Reteste com os dados originais — versão 1.0.0+7

Após o usuário autenticar novamente, a Visão geral exibiu as 4 posições ativas
e o lançamento de teste cancelado de R$ 0,01 **antes de sincronizar**. A lista
de contas e o inventário de Dados e backup confirmaram 4 contas e 1 lançamento.
Isso confirma o acesso ao armazenamento anterior pela aplicação corrigida.

Foram conferidos na janela nativa:

- Novo compromisso abre diretamente o formulário com a conta elegível
  preenchida; cancelar retorna sem criar regra.
- Relatórios e Patrimônio carregam as posições existentes. Os resultados de
  movimentação confirmada são zero, pois o único lançamento está cancelado.
- As cinco telas de Mais abrem e a seta retorna à seção.
- A fatura do cartão abre após a transformação do cartão; ciclo, saldo, limite
  e ausência de compras são exibidos. Nenhum pagamento foi registrado.
- Dados e backup apresenta o inventário correto. Não foi executada restauração.
- Tema claro funciona; Seguir o sistema foi restaurado. Privacidade oculta os
  valores da Visão geral e a visualização original foi restabelecida.

O ciclo remoto foi iniciado com 0 pendentes. A conclusão e o cursor foram
persistidos no SQLite, mas a tela continuou em Sincronizando. Esse fluxo não foi
considerado aprovado nessa versão: o serviço aguardava o encerramento assíncrono
do observador de identidade depois de já salvar o resultado.

## Correção da conclusão da sincronização

Cancelar a assinatura interrompe a entrega de eventos imediatamente, conforme
o contrato de `StreamSubscription.cancel`. A limpeza assíncrona do observador
agora não bloqueia o resultado financeiro já concluído ou sua falha. A proteção
contra troca de identidade continua ativa durante toda a operação.

Dois testes reproduziram o travamento com limpeza pendente e passaram após a
correção. Um terceiro verifica que erro na limpeza não substitui um resultado
persistido. Os testes também verificam novo ciclo e retomada após falha; a
sessão real foi retestada na versão 1.0.0+8, conforme resultado abaixo.

## Verificação automática das correções

- 552 testes Flutter aprovados e análise sem problemas.
- Treze testes novos cobrem os cinco retornos em celular/desktop e o requisito
  de conta, cancelamento, navegação e formulário com conta ativa.
- Quatro novas capturas cobrem desktop e 320px com texto 2×; a captura anterior
  de planejamento vazio foi atualizada para a ação que agora responde.
- Testes do empacotador aprovados, incluindo a identidade de armazenamento.
- Revisão independente com perfil alternativo: **ship**. Detector sem achados.

## Pacotes finais — versão 1.0.0+8

Builds release Windows e Android concluídos. O executável Windows foi reaberto
com nome visível Pollar e identidade de armazenamento `com.pollar/pollar_app`.
O ZIP foi aberto e seus 34 arquivos foram conferidos contra o manifesto,
incluindo tamanho e SHA-256. O APK foi inspecionado com aapt: pacote
`com.pollar.pollar_app`, nome Pollar, versão `1.0.0`, código `8`.

| Artefato local (fora do Git) | SHA-256 |
| --- | --- |
| `dist/pollar-windows-1.0.0+8-remote-20261104-004720-b8fd8f0c.zip` | `77B30695EB6379796526F4ED8B8560E186F46D9AD9D2AE262868576B220490EA` |
| `dist/pollar-redesign-v1.0.0-8.apk` | `4E8E8AD3065A2206F56372505F639128EF0775F17CC21CD349786C40B698F30F` |

Após o usuário desbloquear a versão 1.0.0+8, a Visão geral manteve as 4
posições ativas e o lançamento cancelado. Em Mais → Sincronização, a fila
mostrava 0 pendentes. Um clique em Sincronizar agora passou por Sincronizando
e retornou a **Dados em dia / Sincronização concluída**, com 0 pendentes,
botão disponível e horário atualizado de 21:27 para 21:49 de 03/11/2026.
A seta do cabeçalho também retornou à raiz de Mais no executável final.

Esta conferência não substitui testes de gravação/restauração, isolamento
remoto entre identidades ou aceite em outro computador. O APK 8 não foi
instalado fisicamente nesta etapa.
