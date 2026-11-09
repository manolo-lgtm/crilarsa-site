// Diseño adaptable: sin desbordamiento lateral, sin cajas que obliguen a deslizar de lado,
// sin fotos rotas y estructura correcta a 390, 768 y 1440 px.
const { test, expect } = require('@playwright/test');

const PAGES = ['/index.html', '/productos.html', '/hidroxido-de-calcio.html', '/yeso-agricola.html', '/planta.html', '/nosotros.html', '/en.html', '/zh-productos.html'];
const WIDTHS = [320, 390, 768, 1440]; // 320 px = texto ampliado al 400 % (WCAG 1.4.10)

test('Diseño adaptable en tres anchos', async ({ page }, info) => {
  test.skip(info.project.name !== 'desktop', 'los anchos se fijan en la prueba');
  test.setTimeout(240000);
  const problems = [];
  for (const w of WIDTHS) {
    await page.setViewportSize({ width: w, height: 900 });
    for (const p of PAGES) {
      await page.goto(p);
      // recorre la página para que carguen las fotos diferidas
      await page.evaluate(async () => {
        document.documentElement.style.scrollBehavior = 'auto';
        for (let y = 0; y < document.body.scrollHeight; y += 500) { window.scrollTo(0, y); await new Promise((r) => setTimeout(r, 60)); }
        window.scrollTo(0, 0);
      });
      await page.waitForTimeout(1200);
      const r = await page.evaluate(() => ({
        overflow: document.documentElement.scrollWidth - window.innerWidth,
        h1: document.querySelectorAll('h1').length,
        sideScroll: [...document.querySelectorAll('main *')]
          .filter((e) => e.clientWidth > 0 && e.scrollWidth > e.clientWidth + 2 && ['auto', 'scroll'].includes(getComputedStyle(e).overflowX) && !e.closest('.gchips'))
          .map((e) => e.tagName + '.' + String(e.className).slice(0, 30)).slice(0, 3),
        broken: [...document.images].filter((i) => i.complete && i.naturalWidth === 0 && i.getAttribute('src')).map((i) => i.getAttribute('src')).slice(0, 3),
      }));
      if (r.overflow > 1) problems.push(`${w}px ${p}: desborda ${r.overflow}px`);
      if (r.h1 !== 1) problems.push(`${w}px ${p}: ${r.h1} h1`);
      if (r.sideScroll.length) problems.push(`${w}px ${p}: hay que deslizar de lado en ${r.sideScroll.join(', ')}`);
      if (r.broken.length) problems.push(`${w}px ${p}: fotos que no cargan ${r.broken.join(', ')}`);
    }
  }
  expect(problems).toEqual([]);
});
