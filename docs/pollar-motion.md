# Movimento Pollar — extensão do redesign

Solicitação do usuário: integrar as quatro referências de movimento ao plano
atual, **sem descartar o redesign existente**. As fases 1–3, tipografia, paleta,
hierarquia, dados e rotas continuam. Este adendo substitui a proibição anterior
de animar dígitos e autoriza uma celebração pontual de meta concluída.

## Tese e orçamento

O momento focal é a continuidade entre uma posição financeira real e sua
explicação: o saldo muda para outro valor real, o cartão abre sua fatura e os
gráficos se transformam quando a série muda. Pressão e seleção têm resposta
curta; listas coordenam a chegada dos primeiros itens sem atrasar ações.

`PollarMotion` define feedback de 140ms, mudança de 240ms, momento focal de
360ms e celebração de 700ms. Stagger soma até cinco passos de 20ms, total
máximo de 340ms. Pressão usa escala 0,98 com hit testing original; tilt é
limitado a 0,035 radianos. Não há loops, sensores, áudio ou espera por animação
em uma operação de persistência. Gráficos e faces dos cartões usam limites de
repintura. O código usa o Flutter instalado, sem nova dependência de runtime.

## Implementado nos fluxos reais

| Referência | Aplicação no Pollar |
| --- | --- |
| Animated Balance | Confirmado da Visão geral opta por `PrivacyAmount.animateChanges`. Dígitos do mesmo comprimento rolam individualmente entre caracteres anterior/atual; mudança de comprimento usa troca vertical do texto. Se houver quebra de linha, o valor exato aparece diretamente. Não é um contador aritmético. |
| Shared Element Morph | Cartão de crédito se transforma no espaço da fatura existente ao abrir/voltar. Os dois extremos optam por `creditIdentity: true`: o shuttle intermediário contém somente azul sólido e ícone de primeiro plano, sem cópia de saldos que possa sobreviver à privacidade. O padrão menta da biblioteca e do catálogo permanece; movimento reduzido remove o `Hero`. |
| Interactive 3D Cards | Cartões ativos inclinam com mouse/toque, sem capturar a rolagem. Ações textuais explícitas viram a face; o verso mostra dívida inicial, limite e ciclo já cadastrados. A face oculta não recebe foco, toque ou semântica; os `FocusNode` existentes passam pelo `PollarButton.focusNode` optativo e restauram o foco à ação visível. |
| Limite utilizado da fatura | O preenchimento anima somente geometria por 360ms (`PollarMotion.focal`). Privacidade remove imediatamente a proporção, inclusive durante a transição, preserva trilho neutro de tamanho fixo e anuncia limite oculto. Movimento reduzido pinta a proporção final sem `Tween`. Valores e percentual semântico permanecem atuais, sem quantias intermediárias. |
| Chart Morphing | Gráficos reais de fluxo mensal e saldo desenham a entrada e interpolam coordenadas entre séries/moedas. Uma troca durante o efeito parte da geometria corrente. Valores textuais e semânticos continuam exatos e atuais. |
| Goal Celebration | Progresso da meta prioritária preenche suavemente. Uma meta que passa de incompleta para concluída após atualização bem-sucedida dispara um único acento radial finito, sem bloquear a tela. Não dispara ao abrir dados existentes, em falha de gravação ou em privacidade. |

Navegação entre as cinco branches preserva o IndexedStack, seus navegadores,
buscas e formulários. Algumas subrotas recebem transição curta; Apple conserva
a página Material que fornece o gesto nativo de retorno. Botões rotulados têm
resposta de pressão e as listas de Transações ganham entrada coordenada.
A busca agora tem controller no estado da tela para preservar também o texto
visível ao alternar entre desktop e celular.

Recarregamentos da Visão geral e de Relatórios conservam os dados já exibidos
durante o cálculo, permitindo animar a chegada dos novos resultados. Primeiro
carregamento e erro mantêm seus estados existentes. Não se modifica fonte,
serviço, regra financeira, armazenamento, identidade ou sincronização.

## Privacidade e acessibilidade

A identidade de crédito usa azul sólido derivado dos papéis existentes:
`creditSurface` é `info` no claro e `infoSoft` no escuro; o primeiro plano é
canvas / texto primário. `PollarCreditSurface` fornece `Theme` local para dinheiro,
máscara, ícones e foco. O limite cadastrado na frente e o saldo devido na fatura
usam 34px. O morph conserva essa identidade sem copiar valores; não introduz
gradiente ou marca bancária, nem substitui a abertura teal 48/40px da Visão geral.

- Somente o `MoneyText` atual fornece semântica do saldo. Quadros anteriores são
  pintura transitória, sem nós acessíveis ou registros financeiros sintéticos.
- Ocultar valores remove imediatamente o animador e os gráficos, incluindo
  quadros anteriores; máscara e reserva de espaço continuam as da fase 3.
- Movimento reduzido, navegação acessível ou branch inativa cortam efeitos
  próprios. Virar o cartão continua disponível sem transição.
- A meta prioritária oculta proporção e percentual em privacidade. A celebração
  é decorativa, ignora ponteiro e não substitui o feedback textual de sucesso.
- Trocas de moeda não rolam dígitos de uma moeda para outra.

## Amostra isolada e limites

`tool/motion_catalog.dart` abre uma amostra explicitamente demonstrativa, sem
perfil, autenticação ou banco. A partir de `apps/pollar_app`:

```powershell
flutter run -d windows -t tool/motion_catalog.dart
```

`test/goldens/motion_golden_test.dart` cobre quadros intermediários no celular,
mouse no desktop e tema escuro com movimento reduzido. A opção de teste
`--dart-define=POLLAR_EXPORT_MOTION=true` exporta 32 quadros em
`build/motion-preview/`; `dist/pollar-motion-preview.gif` é uma prévia local.

Testes verificam interrupções, semântica exata, privacidade, moeda, foco de
teclado, atualização real do provedor financeiro, busca entre branches e meta
com persistência pendente/falha/sucesso. Isso não mede FPS em aparelho físico
nem equivale a um aceite de leitor de tela ou gesto iOS em hardware.

O refinamento de crédito acrescenta cobertura de contraste em dois temas,
flip por teclado com restauração do foco, privacidade durante o flip, shuttle
neutro na rota real e remoção do `Hero` em movimento reduzido. A fatura cobre
reserva de geometria em três larguras, texto ampliado, pendências e valores
extremos, além de ocultação no meio da animação de limite e saída estática
reduzida. Capturas atuais incluem os versos `accounts_credit_back_390.png` e
`accounts_credit_back_1440_dark.png`, além de `statement_pending_390x844.png`,
`statement_privacy_1200_dark.png`, `statement_390_2x.png` e
`statement_320_130pct.png`, em `apps/pollar_app/test/goldens/`. O resultado final
de suíte, análise e build fica em `docs/redesign-progress.md`.

Contas comuns ainda não têm uma tela própria de detalhe; o morph usa a fatura
real do cartão. Não foram inventados verso com PAN/CVV, investimentos, séries,
seletor de período de Relatórios ou novos destinos. O refinamento visual da
fase 4 registra agora esta etapa de cartões/faturas; as demais etapas e o
polimento transversal seguem seu registro no plano.
