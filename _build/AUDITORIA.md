# Lista de auditoría de crilarsa.com

Lista persistente para no repetir verificaciones. Al cerrar un punto, anotar la fecha y la evidencia.

## Verificado (9 nov 2026)

- [x] **Recorridos A–E**, guía, carrito, WhatsApp y correo: pruebas automáticas en cada publicación.
- [x] **Calculadora** (Neutrocal 45 kg, Cal Forte 25 kg, zeolita 25 kg):
  - 10 t = 400 sacos.
  - 1 t = 23 sacos con 35 kg de excedente.
  - Rechaza 0, negativos y más de 5.000 t.
- [x] **Guía:** las 7 actividades con todas sus necesidades llevan a un producto. Desde la recomendación se puede agregar al pedido.
- [x] **Fichas:** las 5 están en HTML y en PDF etiquetado (con /StructTreeRoot, idioma y título), enlazadas desde el catálogo, la tabla comparativa y cada página de producto.
- [x] **Rastreo y datos estructurados:** 63 URL en el sitemap, canónicas correctas, un solo H1, JSON-LD válido y sin ofertas ni reseñas.
- [x] **Accesibilidad:** axe sin problemas graves en portada, productos y la página en inglés. Foco visible de 3 px. scroll-padding de 96 px para que el menú fijo no tape el foco.
- [x] **Seguridad:** CSP y política de referencia en meta; sin scripts externos; ningún `target=_blank` sin noopener; sin enlaces http. Revisión de secretos y archivos prohibidos en cada ejecución de CI.
- [x] **Diseño:** sin desbordamiento lateral a 390, 768 y 1440 px.
- [x] **Afirmaciones técnicas:** matizadas. Las cifras de logística aparecen como "hasta" y la carga es con cita.

## Pendiente (requiere a la empresa)

- [ ] **Yeso agrícola:** % de CaSO₄, % de S, granulometría y peso del saco.
- [ ] **Mezcla 3:1:** porcentajes de etiqueta y granulometría.
- [ ] **Registro INP:** número del registro, o retirar la mención.
- [ ] **Google Search Console y Analytics:** iniciar sesión con finanzas@crilarsa.com.

## Limitaciones conocidas

- **Cabeceras:** GitHub Pages no permite cabeceras HTTP propias (HSTS, X-Frame-Options); por eso la CSP va en una etiqueta meta.
- **Caché:** de 10 minutos, fijada por GitHub Pages.
- **Datos de rendimiento:** no hay datos de visitantes reales (CrUX) ni de INP; solo mediciones de laboratorio.

## Lecciones
- `build-i18n.ps1 -Out` necesita la ruta absoluta de `deploy`. Con una ruta relativa escribe en la carpeta actual y los diccionarios publicados quedan desactualizados (pasó hasta el 9 nov 2026).
- El commit por la web de GitHub se pierde si se sale de la página mientras dice 'Processing your files'.
