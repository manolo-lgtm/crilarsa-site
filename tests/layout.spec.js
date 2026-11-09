// Diseño adaptable: sin desbordamiento lateral y estructura correcta a 390, 768 y 1440 px.
const { test, expect } = require('@playwright/test');

const PAGES = ['/index.html', '/productos.html', '/hidroxido-de-calcio.html', '/yeso-agricola.html', '/planta.html', '/nosotros.html', '/en.html'];
const WIDTHS = [390, 768, 1440];

test('Diseño adaptable en tres anchos', async ({ page }, info) => {
  test.skip(info.project.name !== 'desktop', 'los anchos se fijan en la prueba');
  const problems = [];
  for (const w of WIDTHS) {
    await page.setViewportSize({ width: w, height: 900 });
    for (const p of PAGES) {
      await page.goto(p);
      const r = await page.evaluate(() => {
        const out = { overflow: document.documentElement.scrollWidth - window.innerWidth, h1: document.querySelectorAll('h1').length };
        return out;
      });
      if (r.overflow > 1) problems.push(`${w}px ${p}: desborda ${r.overflow}px`);
      if (r.h1 !== 1) problems.push(`${w}px ${p}: ${r.h1} h1`);
    }
  }
  expect(problems).toEqual([]);
});
