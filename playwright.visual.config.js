// Pruebas de regresión visual (no bloquean la publicación; el informe muestra las diferencias).
const { defineConfig, devices } = require('@playwright/test');
module.exports = defineConfig({
  testDir: './tests/visual',
  snapshotPathTemplate: '{testDir}/referencias/{arg}{ext}',
  timeout: 60000,
  reporter: [['list'], ['html', { open: 'never', outputFolder: 'informe-visual' }]],
  webServer: { command: 'python3 -m http.server 4173 --bind 127.0.0.1', url: 'http://127.0.0.1:4173/index.html', reuseExistingServer: true },
  use: { ...devices['Desktop Chrome'], baseURL: 'http://127.0.0.1:4173', locale: 'es-EC', timezoneId: 'America/Guayaquil' },
});
