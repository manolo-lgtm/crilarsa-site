// Pruebas de extremo a extremo de crilarsa.com (sitio estático).
// Nunca se envía un mensaje real: los enlaces de WhatsApp y correo solo se inspeccionan, no se abren.
const { test, expect } = require('@playwright/test');
const AxeBuilder = require('@axe-core/playwright').default;

const WA = 'wa.me/593985211202';
const errors = [];

test.beforeEach(async ({ page }) => {
  page.on('pageerror', (e) => errors.push(`${page.url()} :: ${e.message}`));
  page.on('console', (m) => { if (m.type() === 'error' && !/favicon|ERR_|net::|Failed to load resource/i.test(m.text())) errors.push(`${page.url()} :: ${m.text()}`); });
});
test.afterEach(async () => { expect(errors, errors.join('\n')).toEqual([]); errors.length = 0; });

async function waText(page, sel) {
  const href = await page.locator(sel).first().getAttribute('href');
  expect(href).toContain(WA);
  return decodeURIComponent(href.split('text=')[1] || '');
}

test('A — productor bananero: guía, cantidad y cotización por WhatsApp', async ({ page }) => {
  await page.goto('/index.html');
  await page.locator('.gchip[data-s="banano"]').click();
  const needs = page.locator('.gsteps .grow').nth(1).locator('.gchip');
  await expect(needs.first()).toBeVisible();
  await needs.filter({ hasText: 'Corregir la acidez' }).click();
  const res = page.locator('#g-out .glist');
  await expect(res).toContainText('Carbonato de calcio');
  await expect(res).toContainText('Mezcla mineral 3:1');
  await expect(page.locator('#g-out .glist a').first()).toHaveAttribute('href', /carbonato-de-calcio\.html|mezcla-3-1\.html/);
  // agrega al pedido directamente desde la recomendación
  const card = page.locator('#g-out .glist li').filter({ hasText: 'Carbonato de calcio' });
  await card.locator('.gadd input').fill('300');
  await card.locator('.gadd button').click();
  await expect(card.locator('.gadd button')).toHaveText(/Agregado/);
  const msg = await waText(page, '#drawer a[href*="wa.me"]');
  expect(msg).toContain('300 sacos de Carbonato de calcio (Neutrocal)');
  expect(msg).toContain('≈ 13,5 t');
  expect(msg).toContain('Sector: Bananero');
});

test('B — comprador industrial: cal hidratada, especificaciones y cotización por volumen', async ({ page }) => {
  await page.goto('/hidroxido-de-calcio.html');
  const spec = page.locator('table.spec');
  await expect(spec).toBeVisible();
  await expect(spec).toContainText('Ca(OH)₂');
  await expect(spec).toContainText('73–79 % Ca(OH)₂');
  await expect(spec).toContainText('Saco de 25 kg');
  await expect(page.locator('.speclinks a[href="ficha-cal-forte.pdf"]')).toHaveCount(1);
  const pdf = await page.request.get('/ficha-cal-forte.pdf');
  expect(pdf.status()).toBe(200);
  // calculadora: 10 t con sacos de 25 kg = 400 sacos exactos
  await page.locator('.calc summary').click();
  await page.locator('.calc input').fill('10');
  await page.locator('.calc .cgo').click();
  await expect(page.locator('.calc .cres')).toContainText('400 sacos');
  await page.locator('.calc .cuse').click();
  await expect(page.locator('#producto .qty input')).toHaveValue('400');
  await page.locator('#producto .add').click();
  const msg = await waText(page, '#drawer a[href*="wa.me"]');
  expect(msg).toContain('400 sacos de Hidróxido de calcio (Cal Forte)');
  expect(msg).toContain('≈ 10 t');
  const mail = await page.locator('#drawer a[href^="mailto:"]').first().getAttribute('href');
  expect(mail.startsWith('mailto:finanzas@crilarsa.com')).toBeTruthy();
  expect(decodeURIComponent(mail)).toContain('400 sacos');
});

test('C — camaronera: guía sin dosis y solicitud de asistencia técnica', async ({ page }) => {
  await page.goto('/index.html');
  await page.locator('.gchip[data-s="camaron"]').click();
  await page.locator('.gsteps .grow').nth(1).locator('.gchip').filter({ hasText: 'No estoy seguro' }).click();
  const out = page.locator('#g-out');
  await expect(out.locator('.glist li')).toHaveCount(3);
  const txt = await out.innerText();
  expect(txt).not.toMatch(/\d+\s*(kg|g|t)\s*\/\s*(ha|m2|m²)/i); // ninguna dosis recomendada
  await expect(page.locator('.gdisc')).toContainText(/reemplaza/i);
  const msg = await waText(page, '#g-out a.btn-wa');
  expect(msg).toContain('Acuicultura y camarón');
  // cada combinación ofrecida lleva a un producto
  for (const s of ['banano', 'camaron', 'agricola', 'pecuario', 'azucar', 'agua', 'construccion']) {
    await page.locator(`.gchip[data-s="${s}"]`).click();
    const chips = page.locator('.gsteps .grow').nth(1).locator('.gchip');
    const n = await chips.count();
    expect(n).toBeGreaterThan(0);
    for (let i = 0; i < n; i++) {
      await chips.nth(i).click();
      await expect(out.locator('.glist li').first()).toBeVisible();
    }
  }
});

test('D — móvil: catálogo, tabla técnica, sacos y pedido', async ({ page }, info) => {
  test.skip(info.project.name !== 'mobile', 'solo móvil');
  await page.goto('/zeolita.html');
  const ow = await page.evaluate(() => document.documentElement.scrollWidth - window.innerWidth);
  expect(ow).toBeLessThanOrEqual(1);
  await expect(page.locator('table.spec')).toContainText('Clinoptilolita natural');
  await page.locator('#producto .qty button[data-d="1"]').click();
  await expect(page.locator('#producto .qty input')).toHaveValue('150');
  await page.locator('#producto .add').click();
  // en celular el pedido se abre desde la barra inferior, que muestra el número de productos
  await expect(page.locator('#mbar-q .mq-n')).toHaveText('1');
  await page.locator('#mbar-q').click();
  await expect(page.locator('#drawer')).toBeVisible();
  const msg = await waText(page, '#drawer a[href*="wa.me"]');
  expect(msg).toContain('150 sacos de Zeolita');
  expect(msg).toContain('≈ 3,75 t');
});

test('E — entradas incorrectas, producto sin peso verificado, carrito vacío y volver atrás', async ({ page }) => {
  await page.goto('/carbonato-de-calcio.html');
  await page.evaluate(() => localStorage.removeItem('crilarsa-pedido'));
  await page.reload();
  const qty = page.locator('#producto .qty input');
  const err = page.locator('#producto .qerr').first();
  for (const v of ['', '-5', '0', '2.5', '1000000']) {
    await qty.fill(v);
    await page.locator('#producto .add').click();
    await expect(err).toBeVisible();
  }
  expect(await page.evaluate(() => localStorage.getItem('crilarsa-pedido'))).toBeNull();
  // calculadora: cero, negativo y exceso
  await page.locator('.calc summary').click();
  for (const v of ['0', '-2', '9999']) {
    await page.locator('.calc input').fill(v);
    await page.locator('.calc .cgo').click();
    await expect(page.locator('.calc .cout .qerr')).toBeVisible();
  }
  // redondeo hacia arriba con excedente: 1 t / 45 kg = 23 sacos (1.035 kg, 35 kg de excedente)
  await page.locator('.calc input').fill('1');
  await page.locator('.calc .cgo').click();
  await expect(page.locator('.calc .cres')).toContainText('23 sacos');
  await expect(page.locator('.calc .cex')).toContainText('35 kg');
  // sin peso verificado no hay calculadora
  await page.goto('/yeso-agricola.html');
  await expect(page.locator('.calc')).toHaveCount(0);
  await page.goto('/mezcla-3-1.html');
  await expect(page.locator('.calc')).toHaveCount(0);
  // carrito persiste al volver atrás
  await page.goto('/carbonato-de-calcio.html');
  await page.locator('#producto .qty input').fill('5');
  await page.locator('#producto .add').click();
  await page.goto('/nosotros.html');
  await page.goBack();
  expect(await page.evaluate(() => JSON.parse(localStorage.getItem('crilarsa-pedido'))[0].q)).toBe(5);
});

test('Teclado: la guía y el pedido funcionan sin ratón', async ({ page }) => {
  await page.goto('/index.html');
  await page.locator('.gchip[data-s="agua"]').focus();
  await page.keyboard.press('Enter');
  const first = page.locator('.gsteps .grow').nth(1).locator('.gchip').first();
  await first.focus();
  await page.keyboard.press('Enter');
  await expect(page.locator('#g-out .glist li').first()).toBeVisible();
});

test('Accesibilidad: sin problemas graves (axe) en portada y fichas de producto', async ({ page }) => {
  for (const p of ['/index.html', '/productos.html', '/hidroxido-de-calcio.html', '/yeso-agricola.html', '/planta.html', '/ficha-zeolita.html', '/en.html']) {
    await page.goto(p);
    const r = await new AxeBuilder({ page }).analyze();
    const bad = r.violations.filter((v) => ['serious', 'critical'].includes(v.impact));
    expect(bad.map((v) => `${p} ${v.id}: ${v.nodes.length}`)).toEqual([]);
  }
});

test('Rastreo: sitemap, enlaces internos, imágenes, canónicas y datos estructurados', async ({ page, request }, info) => {
  test.skip(info.project.name !== 'desktop', 'una vez basta');
  const robots = await (await request.get('/robots.txt')).text();
  expect(robots).toContain('Sitemap: https://crilarsa.com/sitemap.xml');
  const sm = await (await request.get('/sitemap.xml')).text();
  const urls = [...sm.matchAll(/<loc>([^<]+)<\/loc>/g)].map((m) => m[1]);
  expect(urls.length).toBeGreaterThanOrEqual(63);
  const assets = new Set(); const problems = [];
  for (const u of urls) {
    const path = u.replace('https://crilarsa.com/', '/') || '/';
    const res = await request.get(path === '/' ? '/index.html' : path);
    if (res.status() !== 200) { problems.push(`${path} ${res.status()}`); continue; }
    const html = await res.text();
    const canon = (html.match(/<link rel="canonical" href="([^"]+)"/) || [])[1];
    if (canon !== u) problems.push(`canónica ${path} -> ${canon}`);
    if ((html.match(/<h1[\s>]/g) || []).length !== 1) problems.push(`h1 ${path}`);
    for (const m of html.matchAll(/<script type="application\/ld\+json">([\s\S]*?)<\/script>/g)) {
      try { const d = JSON.parse(m[1]); if (/"offers"|"aggregateRating"|"review"/.test(m[1])) problems.push(`schema con ofertas/reseñas ${path}`); void d; } catch (e) { problems.push(`JSON-LD inválido ${path}`); }
    }
    for (const m of html.matchAll(/(?:href|src)="([a-z0-9][a-z0-9._-]*\.(?:html|pdf|jpg|jpeg|png|svg|mp4|webp))(?:#[^"]*)?"/gi)) assets.add(m[1]);
  }
  for (const a of assets) { const r = await request.head('/' + a); if (r.status() !== 200) problems.push(`roto ${a} ${r.status()}`); }
  expect(problems).toEqual([]);
});

test('Ruta por sector: el selector de sectores sigue funcionando', async ({ page }) => {
  await page.goto('/index.html');
  await page.locator('#t-agricola').click();
  const li = page.locator('#agricola li[data-p="zeolita"]');
  await li.locator('.qty input').fill('20');
  await li.locator('.add').click();
  const msg = await waText(page, '#drawer a[href*="wa.me"]');
  expect(msg).toContain('20 sacos de Zeolita');
  expect(msg).toContain('Sector: Agricultura: cacao, arroz, palma');
});

test('Guía: agregar desde la recomendación rechaza cantidades no válidas', async ({ page }) => {
  await page.goto('/index.html');
  await page.evaluate(() => localStorage.removeItem('crilarsa-pedido'));
  await page.reload();
  await page.locator('.gchip[data-s="agua"]').click();
  await page.locator('.gsteps .grow').nth(1).locator('.gchip').first().click();
  const card = page.locator('#g-out .glist li').first();
  for (const v of ['0', '-4', '1.5', '200000']) {
    await card.locator('.gadd input').fill(v);
    await card.locator('.gadd button').click();
    await expect(card.locator('.qerr')).toBeVisible();
  }
  expect(await page.evaluate(() => localStorage.getItem('crilarsa-pedido'))).toBeNull();
});

test('Catálogo: tabla comparativa de los 5 productos con fichas HTML y PDF', async ({ page, request }) => {
  await page.goto('/productos.html');
  const rows = page.locator('table.compare tbody tr');
  await expect(rows).toHaveCount(5);
  for (const f of ['neutrocal', 'cal-forte', 'zeolita', 'yeso-agricola', 'mezcla-3-1']) {
    expect((await request.get(`/ficha-${f}.html`)).status()).toBe(200);
    const pdf = await request.get(`/ficha-${f}.pdf`);
    expect(pdf.status()).toBe(200);
    expect((await pdf.body()).toString('latin1')).toContain('/StructTreeRoot'); // PDF etiquetado (accesible)
  }
});

test('Seguridad: CSP, política de referencia, sin scripts externos ni enlaces inseguros', async ({ page }) => {
  for (const p of ['/index.html', '/zeolita.html', '/en.html', '/ficha-zeolita.html']) {
    await page.goto(p);
    await expect(page.locator('meta[http-equiv="Content-Security-Policy"]')).toHaveCount(1);
    await expect(page.locator('meta[name="referrer"]')).toHaveCount(1);
    expect(await page.locator('script[src]').count()).toBe(0);
    expect(await page.locator('a[target="_blank"]:not([rel*="noopener"])').count()).toBe(0);
    expect(await page.locator('[src^="http:"], a[href^="http:"]').count()).toBe(0);
  }
});

test('Fichas: los botones de ficha y PDF son legibles en la página de producto', async ({ page }) => {
  await page.goto('/hidroxido-de-calcio.html');
  const a = page.locator('.speclinks a').first();
  await expect(a).toBeVisible();
  const c = await a.evaluate((e) => [getComputedStyle(e).color, getComputedStyle(e).backgroundColor]);
  expect(c[0]).not.toBe(c[1]);
  expect(c[0]).not.toBe('rgb(255, 255, 255)');
});

test('Movimiento reducido: sin video automático ni desplazamiento animado', async ({ browser }, info) => {
  test.skip(info.project.name !== 'desktop', 'una vez basta');
  const ctx = await browser.newContext({ reducedMotion: 'reduce', locale: 'es-EC', timezoneId: 'America/Guayaquil' });
  const page = await ctx.newPage();
  await page.goto('/index.html');
  await page.waitForTimeout(4000);
  const r = await page.evaluate(() => ({
    videos: [...document.querySelectorAll('.hero-reel video')].filter((v) => v.getAttribute('src')).length,
    scroll: getComputedStyle(document.documentElement).scrollBehavior,
  }));
  expect(r.videos).toBe(0);
  expect(r.scroll).toBe('auto');
  await ctx.close();
});
