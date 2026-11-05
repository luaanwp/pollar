# Navegação horizontal do Pollar

O usuário pediu a remoção da navegação lateral no Windows, preservando o
redesign e suas animações. A alteração é de estrutura dentro da identidade
existente: marca Pollar, Inter, Lucide e cores dos dois temas.

## Referências e decisão

O [NICE Design System](https://design-system.nice.org.uk/components/horizontal-navigation/)
descreve navegação horizontal como forma de liberar a largura para o conteúdo,
com a restrição de haver poucos destinos bem definidos. O Pollar tem cinco.

Uma [discussão sobre a lateral do Figma](https://www.reddit.com/r/FigmaDesign/comments/1qb20oh/new_left_navigation_bar_sucks_anyone_else_not/)
relata perda de espaço em telas pequenas, com opiniões também favoráveis à
lateral. Outra [discussão de abas em ferramentas de produtividade](https://www.reddit.com/r/UXDesign/comments/1tdjk6o/why_are_so_many_productivity_apps_shipping_locked/)
discute o atrito de separar os destinos usados com frequência. São relatos
qualitativos, sem demonstrar uma preferência universal. A escolha atende à
preferência explícita do usuário e às cinco seções atuais do aplicativo.

## Implementação

- Abaixo de 600dp: navegação inferior existente, com os mesmos rótulos.
- A partir de 600dp: marca à esquerda, destinos no topo e privacidade/tema à
  direita. Uma linha quando a medição real dos textos permite; caso contrário,
  marca e utilidades precedem uma segunda linha de navegação.
- Rótulos completos, alvos de pelo menos 48dp, foco visível e seleção semântica.
  Se o menu excede a largura, permite rolagem e revela o destino selecionado
  após troca de seção ou redimensionamento.
- Um sublinhado teal acompanha a seleção em 240ms; movimento reduzido remove
  essa animação. A ordem visual e o indicador respeitam RTL.
- O retorno de destinos de Mais continua explícito. No desktop, apresenta
  também o texto Voltar para Mais.
- O cabeçalho não repete o nome da página. Transações conserva seu único
  título no celular. A área larga de dica do antigo nome foi removida; dicas
  úteis aguardam 2 segundos de hover e ficam junto ao controle correspondente.
- O StatefulNavigationShell e seus navegadores permanecem os mesmos. A troca
  de composição não apaga formulários, buscas ou pilhas de detalhes.

O custo em janelas estreitas é uma linha adicional de cabeçalho; a rolagem
horizontal evita comprimir ou ocultar rótulos. Dados financeiros, sincronização,
autenticação e atualização de versão mantêm seus contratos.

## Verificação

As capturas cobrem desktop claro/escuro, largura intermediária, janela curta
com texto 2× e celular. Testes verificam teclado, áreas seguras, mudança de
largura, preservação de rascunhos/pilhas, visibilidade da seleção e RTL.
As capturas aprovadas do telefone permanecem iguais; paisagem com largura de
tablet passa a usar a navegação superior. Isso não equivale a teste físico de
leitor de tela ou medição de FPS.

A suíte local completa passou com **574 testes**, com comparação das capturas
habilitada, e a análise não encontrou problemas. A revisão independente das
capturas desktop/celular e do código terminou com **ship**, sem achados materiais.
