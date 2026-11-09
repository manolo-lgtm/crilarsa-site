// Regresión visual: compara secciones clave con las imágenes de referencia guardadas en el repositorio.
// Si una diferencia es intencional, se actualizan las referencias con el flujo "Actualizar referencias visuales".
const { test, expect } = require('@playwright/test');

const SHOTS = [
  { name: 'guia', path: '/index.html', sel: '#guia' },
  { name: 'comparar', path: '/productos.html', sel: '#comparar' },
  { name: 'especificaciones', path: '/hidroxido-de-calcio.html', sel: '#especificaciones' },
];

for (const w of [390, 768, 1440]) {
  for (const s of SHOTS) {
    test(`${s.name} a ${w}px`, async ({ page }) => {
      await page.setViewportSize({ width: w, height: 900 });
      await page.goto(s.path);
      await page.addStyleTag({ content: '*{animation:none!important;transition:none!important} .rv{opacity:1!important;transform:none!important}' });
      const el = page.locator(s.sel);
      await el.scrollIntoViewIfNeeded();
      await expect(el).toHaveScreenshot(`${s.name}-${w}.png`, { maxDiffPixelRatio: 0.02 });
    });
  }
}
