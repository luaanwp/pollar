// npm install --prefix ../../dist/brand-tools --no-audit --no-fund @resvg/resvg-js@2.6.2
// Run from apps/pollar_app: node tool/render_brand_assets.cjs
const fs = require('node:fs');
const path = require('node:path');
const app = path.resolve(__dirname, '..');
const { Resvg } = require(path.resolve(app, '../../dist/brand-tools/node_modules/@resvg/resvg-js'));
const brand = path.join(app, 'assets/brand');
function render(source, target, width) {
  const result = new Resvg(fs.readFileSync(path.join(brand, source)), {
    fitTo: { mode: 'width', value: width },
  }).render();
  fs.writeFileSync(target, result.asPng());
}
for (const name of ['pollar-symbol-teal', 'pollar-symbol-mint', 'pollar-logo-teal', 'pollar-logo-mint', 'pollar-app-icon']) {
  render(`${name}.svg`, path.join(brand, `${name}.png`), 1024);
}
for (const [density, width] of Object.entries({ mdpi: 48, hdpi: 72, xhdpi: 96, xxhdpi: 144, xxxhdpi: 192 })) {
  render('pollar-app-icon.svg', path.join(app, `android/app/src/main/res/mipmap-${density}/ic_launcher.png`), width);
}
for (const width of [192, 512]) {
  render('pollar-app-icon.svg', path.join(app, `web/icons/Icon-${width}.png`), width);
  render('pollar-app-icon.svg', path.join(app, `web/icons/Icon-maskable-${width}.png`), width);
}
render('pollar-app-icon.svg', path.join(app, 'web/favicon.png'), 32);
console.log('Rendered flat PNG logos, app icon, Android legacy and web icons.');
