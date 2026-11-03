# Pollar — marca

Reconstrução vetorial das duas referências aprovadas pelo usuário. As superfícies
são sólidas: verde `#087F6B`, menta `#5ED3B8` e fundo escuro `#0C1211`.

- `pollar-symbol-*.svg`: símbolo isolado, fundo transparente.
- `pollar-logo-*.svg`: assinatura horizontal, fundo transparente e letras em
  contornos vetoriais. Inter SemiBold, peso 600, alivia o peso do nome em relação
  à referência. Não exige fonte instalada para abrir ou imprimir.
- `pollar-app-icon.svg`: símbolo menta sobre fundo escuro quadrado; o sistema
  operacional aplica a máscara do launcher.
- Arquivos PNG são exportações dos SVGs, com transparência onde aplicável.

Todas as variantes usam o mesmo contorno do P, inclusive seu recorte diagonal.
Preserve proporções, espaço negativo e cores; não adicione texturas, gradientes,
sombras ou contornos. Mantenha uma margem livre de pelo menos um quarto da altura
do símbolo ao redor da marca isolada. O launcher adaptativo tem margem própria
para acomodar máscaras circulares, quadradas e variantes do Android.

## Reprodução

Geometria e paleta: `tool/brand_geometry.json`. A partir de `apps/pollar_app`:

```text
python -m pip install fonttools pillow
npm install --prefix ../../dist/brand-tools --no-audit --no-fund @resvg/resvg-js@2.6.2
python tool/generate_brand_assets.py
node tool/render_brand_assets.cjs
python tool/export_windows_icon.py
```

O primeiro script gera SVGs, contornos do nome, caminho Dart e vetores Android.
O segundo exporta PNGs, ícones legados Android e ícones web usando resvg.
Essas ferramentas são de geração; não são dependências de execução do app.
O ICO Windows é a exportação do ícone em 16/24/32/48/64/128/256px.
Inter é distribuída sob [SIL OFL 1.1](../fonts/inter/OFL.txt).
