# Formulários e entrada monetária

Em builds de desenvolvimento, abra **Preferências → Abrir catálogo de componentes**
ou a rota `/design-system`. A rota antiga `/design-system/forms` redireciona para
o catálogo unificado. Esse ambiente é apenas de demonstração; validar
não grava transações. A rota e o acesso não são registrados em release/profile.

## Contrato de entrada

- `CurrencyInput` usa edição decimal pt-BR: `100` corresponde a 100 unidades;
  `100,50` corresponde a 100 unidades e 50 centavos em BRL.
- Aceita símbolo/código da moeda e agrupamento válido (`R$ 1.234,56`).
- Não altera o texto durante a edição, preservando seleção, colagem e composição.
- Texto vazio/inválido emite `null`: o consumidor nunca deve enviar o último
  valor válido enquanto a entrada atual é inválida. Integra-se à validação de `Form`.
- Valores negativos exigem `allowNegative`. A precisão respeita `Currency`.
- O parser rejeita valores acima de 9.007.199.254.740.991 unidades menores para
  preservar a representação exata tanto em Dart nativo quanto no web.
- `initialValue` é o valor inicial/reset, não uma propriedade controlada. Para
  trocar a moeda ou o registro editado, recrie o campo com uma nova `Key`.

## Prévia de parcelas

Divisão inteira com resto distribuído nas primeiras parcelas: 10.000 centavos
em três parcelas resulta em 3.334 + 3.333 + 3.333. A prévia lista grupos distintos
sem arredondar o total. Contagem suportada neste componente: 1–360; este limite
protege a prévia, não representa política de uma instituição financeira.
Não calcula juros, datas de fechamento, vencimentos ou faturas. Valores muito
pequenos podem produzir parcelas de zero; o fluxo de compra deverá validar isso
segundo as regras do produto antes de persistir um plano.

## Continuação

O catálogo geral, os estados financeiros e os componentes de confirmação estão
prontos. O domínio e os casos de uso de contas agora vivem na feature `accounts`;
o próximo passo é conectar os formulários à apresentação da feature. Persistência
Drift, autenticação e sincronização continuam pendentes.
