# M11 – Proyecto Integrador Final · RetailPro

**Alumno:** Leandro Jofre · Data Analytics (Coderhouse)

Entrega final del curso: SQL, estadística aplicada y Power BI integrados en un caso de negocio.

## Contenido de la carpeta

| Archivo | Qué es |
|---|---|
| `Jofre_Leandro_Proyecto_Final.pdf` | Documento de entrega (el mismo que se subió a la plataforma) |
| `Proyecto_Final_RetailPro_Jofre.pbix` | Tablero de Power BI (7 páginas + 2 tooltips) |
| `01_crear_base_y_cargar_crudos.sql` | Ejercicio 1: crea la base `ProyectoFinal_Jofre` y carga los CSV crudos |
| `02_eda.sql` | Ejercicio 1: 9 consultas de análisis exploratorio |
| `03_limpieza_y_modelo.sql` | Ejercicio 1: limpieza y tablas definitivas con PK y FK |
| `04_consulta_ultimos_30_dias.sql` | Ejercicio 1: consulta de ventas de los últimos 30 días |

## Cómo reproducir el Ejercicio 1

Ejecutar los scripts en SQL Server en orden: 01 → 02 → 03 → 04.

## Cómo abrir el tablero

Abrir el `.pbix` con Power BI Desktop. Los datos ya están cargados en el archivo, así que se puede navegar sin conexión. Para **Actualizar** hace falta la base `RetailPro_DB` en un SQL Server local (`localhost`).

## Pregunta de negocio

¿Cuándo y en qué categoría cayeron las ventas de la región Norte en 2024, y qué acción comercial conviene tomar para revertirlo?

**Respuesta corta:** Norte cae −13,9 % mientras la empresa crece +17,6 %. La caída se concentra en equipos caros de Computación (ventas de alto valor de 32 a 21). Acción prioritaria: revisar stock, precios y promociones de Computación en el Norte.
