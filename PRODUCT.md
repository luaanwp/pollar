# Product

<!-- impeccable:product-schema 1 -->

> Registro inferido dos documentos e do código existentes, conforme a autorização
> contínua para avançar. Decisões ainda não implementadas permanecem abertas.

## Platform

adaptive

## Users

Pessoas que administram as próprias finanças em português do Brasil, alternando
entre computador e celular para registrar movimentos, conferir saldos e planejar.

## Product Purpose

O Pollar organiza contas, cartões, transações e planejamento financeiro com
valores exatos, histórico preservado e leitura clara do saldo confirmado e
projetado. Sucesso significa registrar e compreender cada movimento sem perder
precisão ou confiança nos totais.

## Positioning

Um livro-caixa pessoal sereno: regras contábeis explícitas, operação local
confiável e privacidade visível, sem gamificação nem simplificação dos números.

## Operating Context

- Cadastro e consulta frequente de receitas, despesas e transferências.
- Uso rápido no celular e análise mais densa no desktop.
- Valores podem ser ocultados sem remover contexto ou alterar o layout.
- O produto começa local-first; sincronização remota é uma etapa posterior.

## Capabilities and Constraints

- Flutter adaptativo para Windows, Android e iOS; navegador não é alvo da V1.
- Localidade padrão pt-BR e moeda inicial BRL, com modelo preparado para outras moedas.
- Dinheiro é armazenado em unidades menores inteiras, nunca em ponto flutuante.
- Estados de transação: Previsto, Pendente, Compensado, Conciliado e Cancelado.
- Transferências e pagamentos de fatura não contam como receita ou despesa.
- Exclusões financeiras preservam histórico por arquivamento ou cancelamento.
- A V2 pode alterar telas, armazenamento e sincronização sem reescrever domínio.

## Brand Commitments

O nome é Pollar. A voz é calma, direta e específica, sem exclamações,
gamificação ou elogios. A identidade visual e os componentes vigentes estão em
`DESIGN.md` e no skill local `pollar-design`.

## Evidence on Hand

- Regras e roadmap: `pollar_prompts_finance_app.md`.
- Sistema visual: `DESIGN.md`, `pollar_design_system.md` e tokens locais.
- Implementação Flutter funcional com testes de arquitetura, domínio e interface.
- Não há pesquisa de usuários, métricas públicas, depoimentos ou alegações comerciais.

## Product Principles

- Precisão financeira antes de conveniência aparente.
- Privacidade acessível e previsível.
- Complexidade revelada progressivamente.
- Módulos substituíveis por contratos estreitos.
- Mesma hierarquia de informação, adaptada ao dispositivo.

## Accessibility & Inclusion

Contraste WCAG AA, navegação por teclado, semântica que não depende somente de
cor, alvos de toque adequados e suporte a texto ampliado e movimento reduzido.
