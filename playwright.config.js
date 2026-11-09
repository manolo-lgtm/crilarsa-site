// Configuración de pruebas. Sirve los archivos del repositorio en local; no toca el sitio en producción.
// BASE_URL permite probar otra copia (por ejemplo, una copia con defectos a propósito en tests/mutantes.js).
const { defineConfig, devices } = require('@playwright/test');
const url = process.env.BASE_URL || 'http://127.0.0.1:4173';
const base = { baseURL: url, locale: 'es-EC', timezoneId: 'America/Guayaquil', screenshot: 'only-on-failure', trace: 'retain-on-failure' };
module.exports = defineConfig({
  testDir: './tests',
  testIgnore: '**/visual/**',
  timeout: 60000,
  retries: process.env.BASE_URL ? 0 : 1,
  reporter: [['list'], ['html', { open: 'never' }]],
  webServer: process.env.BASE_URL ? undefined : { command: 'python3 -m http.server 4173 --bind 127.0.0.1', url: 'http://127.0.0.1:4173/index.html', reuseExistingServer: true },
  projects: [
    { name: 'desktop', use: { ...devices['Desktop Chrome'], ...base } },
    { name: 'mobile', use: { ...devices['Pixel 5'], ...base } },
  ],
});
