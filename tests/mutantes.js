// Prueba de las pruebas: crea copias del sitio con un defecto a propósito ("mutante") en una carpeta temporal
// y comprueba que las pruebas fallen. Si un mutante pasa las pruebas, las pruebas no detectan ese defecto.
// No modifica el sitio real ni el repositorio.
const fs = require('fs');
const path = require('path');
const os = require('os');
const { spawn, spawnSync } = require('child_process');

const ROOT = path.resolve(__dirname, '..');
const MUTANTES = [
  { nombre: 'Calculadora redondea hacia abajo', archivos: ['carbonato-de-calcio.html', 'hidroxido-de-calcio.html'], de: 'Math.ceil(kgReq/p.w)', a: 'Math.floor(kgReq/p.w)', prueba: 'E —' },
  { nombre: 'Número de WhatsApp equivocado', archivos: '*.html', de: '593985211202', a: '593000000000', prueba: 'A —' },
  { nombre: 'Sin validación de cantidad', archivos: ['carbonato-de-calcio.html'], de: "if(!(q>=1)||String(raw).indexOf('.')>-1||q>100000)", a: 'if(false)', prueba: 'E —' },
  { nombre: 'Guía no recomienda productos', archivos: ['index.html'], de: 'N[n].indexOf(li.dataset.p)>-1', a: 'false', prueba: 'C —' },
  { nombre: 'Peso del saco de Cal Forte incorrecto', archivos: ['hidroxido-de-calcio.html'], de: "calforte:{w:25,", a: "calforte:{w:20,", prueba: 'B —' },
  { nombre: 'Política de seguridad eliminada', archivos: ['zeolita.html'], de: '<meta http-equiv="Content-Security-Policy"', a: '<meta name="x-removed"', prueba: 'Seguridad' },
];

function copiarSitio(dest) {
  for (const f of fs.readdirSync(ROOT)) {
    if (['.git', 'node_modules', 'tests', '_build', '.github', 'playwright-report', 'test-results'].includes(f)) continue;
    fs.cpSync(path.join(ROOT, f), path.join(dest, f), { recursive: true });
  }
}

async function main() {
  let sobrevivientes = 0;
  const filas = [];
  for (const [i, m] of MUTANTES.entries()) {
    const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'mutante-'));
    copiarSitio(dir);
    const lista = m.archivos === '*.html' ? fs.readdirSync(dir).filter((f) => f.endsWith('.html')) : m.archivos;
    let aplicados = 0;
    for (const f of lista) {
      const p = path.join(dir, f);
      const t = fs.readFileSync(p, 'utf8');
      if (t.includes(m.de)) { fs.writeFileSync(p, t.split(m.de).join(m.a)); aplicados++; }
    }
    if (!aplicados) { filas.push(`NO APLICADO  ${m.nombre} (el texto a cambiar no existe; actualice este mutante)`); sobrevivientes++; continue; }
    const port = 4200 + i;
    const srv = spawn('python3', ['-m', 'http.server', String(port), '--bind', '127.0.0.1', '-d', dir], { stdio: 'ignore' });
    await new Promise((r) => setTimeout(r, 1500));
    const r = spawnSync('npx', ['playwright', 'test', '--project=desktop', '--project=mobile', '-g', m.prueba, '--reporter=line'], {
      cwd: ROOT, env: { ...process.env, BASE_URL: `http://127.0.0.1:${port}` }, encoding: 'utf8', timeout: 240000,
    });
    srv.kill();
    const detectado = r.status !== 0;
    if (!detectado) sobrevivientes++;
    filas.push(`${detectado ? 'DETECTADO   ' : 'NO DETECTADO'} ${m.nombre} (prueba "${m.prueba}")`);
  }
  console.log('\nResultado de la prueba de mutantes:\n' + filas.join('\n'));
  process.exit(sobrevivientes ? 1 : 0);
}
main();
