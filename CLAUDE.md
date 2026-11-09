# crilarsa.com — guía del proyecto

Sitio estático y público de Crilarsa C.A. (minerales industriales, Guayaquil). Se publica con GitHub Pages. Es gratis y no tiene servidor propio, base de datos ni API.

## Arquitectura
- **Fuente única:** `_build/web/crilarsa-sitio.html`. Contiene el HTML, el CSS y el JS en línea, en español.
- **Datos técnicos:** `_build/fichas-data.ps1` es la única fuente de las fichas (`ficha-*.html` y `ficha-*.pdf`) y de las tablas de especificaciones de las páginas de producto.
- **Páginas generadas (raíz del repositorio):**
  - 9 páginas en español: index, productos, planta, nosotros y las 5 de producto.
  - 54 páginas traducidas (`en-`, `pt-`, `fr-`, `ru-`, `uk-`, `zh-`).
  - `sitemap.xml` y `robots.txt`.
- **Traducciones:** `_build/i18n/es-keys.json` y un archivo `xx.txt` por idioma, con una línea por clave en el mismo orden. Las claves nuevas siempre se agregan al final. El script genera `i18n/xx.json`.
- **Cotización:** el carrito se guarda en `localStorage` (`crilarsa-pedido`, solo productos y cantidades). Se envía abriendo WhatsApp (wa.me/593985211202) o un correo a finanzas@crilarsa.com. El sitio no recibe ni guarda datos de clientes.

## Compilación (Windows PowerShell 5.1; los scripts se guardan en UTF-8 con BOM)
```
_build/make-fichas.ps1           # fichas HTML (los PDF se generan con Chrome headless --print-to-pdf)
_build/build-site.ps1 -Mode deploy
_build/build-i18n.ps1 -Out deploy
_build/build-seo.ps1             # páginas por idioma, canonical/hreflang, JSON-LD, sitemap
```

## Pruebas
- `npm install && npx playwright install chromium && npx playwright test`
- Escenarios: A bananero, B comprador industrial, C camaronera, D móvil y E entradas incorrectas. También cubren teclado, axe (problemas graves), sitemap, enlaces, imágenes, canónicas y JSON-LD.
- Las pruebas nunca envían mensajes: solo revisan los enlaces de WhatsApp y de correo.

## Publicación
- GitHub Actions (`.github/workflows/site.yml`) corre las pruebas en cada push a `main`. Solo publica si todas pasan; si una falla, el sitio publicado no cambia.
- Antes de cada cambio grande se crea una rama de respaldo `respaldo-AAAA-MM-DD-…` desde `main`.

## Marca
- Colores: azul marino `#1e2833` y azul `#3d5a78`, sobre fondo claro.
- Logo: `logo-crilarsa-blanco.png`.
- Íconos de sector en tonos suaves.
- Tono sobrio, técnico y directo de fábrica.
- Las imágenes conceptuales nunca se presentan como fotos reales de la planta.

## Normas de calidad
- No inventar especificaciones, certificaciones, precios, existencias, reseñas ni plazos.
- Los datos de etiqueta no se presentan como resultados de laboratorio certificados.
- Separar las propiedades verificadas de los usos habituales y de los resultados que dependen de las condiciones de cada caso. No dar dosis.
- La calculadora solo funciona con el peso de saco verificado en la etiqueta: Neutrocal 45 kg, Cal Forte 25 kg y zeolita 25 kg.
- Metas: LCP ≤ 2,5 s, INP ≤ 200 ms, CLS ≤ 0,1, sin errores graves de accesibilidad y sin enlaces rotos.

## Confidencialidad
- Ningún dato financiero, de clientes, de facturación, de contabilidad, de proveedores ni de precios no publicados.
- No se integra ningún sistema contable.
- Ninguna credencial en el repositorio.
- Único correo público: finanzas@crilarsa.com.
- La información técnica nueva que no sea pública necesita aprobación de la gerencia antes de publicarse.

## Limitaciones conocidas
- GitHub Pages fija la caché en 10 minutos.
- El DNS está en Squarespace/Google; Cloudflare no está en uso.
- Search Console no está conectado.
- Datos pendientes de confirmar:
  - Yeso agrícola: composición, granulometría y peso del saco.
  - Mezcla 3:1: porcentajes de etiqueta.
  - Número del Registro INP.
