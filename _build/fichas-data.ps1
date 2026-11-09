# Datos técnicos públicos por producto. ÚNICA fuente para las fichas (make-fichas.ps1) y las tablas de las páginas de producto (build-site.ps1).
# Solo datos de etiqueta o ya publicados por Crilarsa. Nada inventado. 'kg' = peso verificado del saco (vacío = no verificado: sin calculadora).
$fichas = @(
 @{key='neutrocal'; file='ficha-neutrocal.html'; name='Carbonato de calcio — Neutrocal'; img='saco-neutrocal.png'; page='carbonato-de-calcio.html'; kg=45;
   rows=@(@('Nombre químico','Carbonato de calcio'),@('Fórmula','CaCO₃'),@('Principio activo (etiqueta)','93–97 % CaCO₃'),@('Granulometría (etiqueta)','Malla 200'),@('Otras granulometrías','Bajo consulta'),@('Presentación','Saco de 45 kg'));
   uses='Acuicultura, agricultura, sanidad animal y construcción de carreteras.';
   lim='Acción gradual: cuando se necesita subir el pH con rapidez se usa cal hidratada. La dosis depende del análisis de suelo o de agua.';
   care='Almacenar en lugar seco y cubierto, sobre pallets. Evitar la humedad. Usar mascarilla contra polvo al manipular.'},
 @{key='calforte'; file='ficha-cal-forte.html'; name='Hidróxido de calcio — Cal Forte'; img='saco-calforte.png'; page='hidroxido-de-calcio.html'; kg=25;
   rows=@(@('Nombre químico','Hidróxido de calcio (cal hidratada)'),@('Fórmula','Ca(OH)₂'),@('Variante (etiqueta)','Cal Forte Plus, Tipo A'),@('Principio activo (etiqueta)','73–79 % Ca(OH)₂'),@('Granulometría (etiqueta)','Malla 300'),@('Presentación','Saco de 25 kg'));
   uses='Acuicultura, agricultura, sanidad animal, construcción y tratamiento de aguas.';
   lim='Producto fuertemente alcalino: no se aplica con camarón en la piscina. Su efecto depende de la dosis y de las condiciones de cada caso.';
   care='Producto alcalino. Usar guantes, gafas y mascarilla; evitar el contacto con ojos y piel. Almacenar en lugar seco, cubierto y alejado de ácidos.'},
 @{key='zeolita'; file='ficha-zeolita.html'; name='Zeolita natural'; img='saco-zeolita.png'; page='zeolita.html'; kg=25;
   rows=@(@('Mineral (etiqueta)','Clinoptilolita natural'),@('SiO₂ total (etiqueta)','76 % (composición química; no equivale al % de clinoptilolita)'),@('Granulometría (etiqueta)','Malla 200'),@('Presentación','Saco de 25 kg'));
   uses='Acuicultura, agricultura, tratamiento de agua e industria azucarera.';
   lim='Retiene amonio y nutrientes por intercambio iónico; se usa junto al fertilizante, no lo reemplaza. Los resultados dependen de la dosis y del sistema.';
   care='Almacenar en lugar seco y cubierto. Usar mascarilla contra polvo al manipular.'},
 @{key='sulfato'; file='ficha-yeso-agricola.html'; name='Sulfato de calcio — Yeso agrícola'; img='saco-sulfato.png'; page='yeso-agricola.html'; kg=0; src='Datos publicados por Crilarsa';
   rows=@(@('Nombre químico','Sulfato de calcio'),@('Fórmula','CaSO₄'),@('Nombre común','Yeso agrícola'),@('Efecto sobre el pH','No eleva el pH del suelo'),@('Aporte','Calcio y azufre'),@('Presentación','Consulte presentaciones disponibles'));
   uses='Agricultura, incluido el cultivo de banano, en suelos y cultivos que requieren calcio y azufre.';
   lim='No corrige la acidez del suelo. Para suelos ácidos se usa carbonato de calcio o la mezcla 3:1.';
   pend='Contenido de CaSO₄, azufre, granulometría y peso del saco: en confirmación. Solicítelos a su asesor.';
   care='Almacenar en lugar seco y cubierto, sobre pallets. Usar mascarilla contra polvo al manipular.'},
 @{key='mezcla'; file='ficha-mezcla-3-1.html'; name='Mezcla mineral 3:1'; img='saco-mezcla.png'; page='mezcla-3-1.html'; kg=0; src='Datos publicados por Crilarsa';
   rows=@(@('Composición','Tres partes de carbonato de calcio (CaCO₃) por una parte de sulfato de calcio (CaSO₄)'),@('Molienda','Ultrafina'),@('Aporte','Corrección de acidez, calcio y azufre en una sola aplicación'),@('Presentación','Saco de 45 kg o 50 kg'));
   uses='Agricultura, con especial interés para el productor bananero.';
   lim='Proporción de formulación 3:1. Los porcentajes garantizados de etiqueta están en confirmación.';
   pend='Porcentajes garantizados en etiqueta (CaCO₃, azufre) y granulometría: en confirmación. Solicítelos a su asesor.';
   care='Almacenar en lugar seco y cubierto, sobre pallets. Evitar la humedad. Usar mascarilla contra polvo al manipular.'}
)
