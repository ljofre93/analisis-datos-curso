# RetailPro - Proyecto integrador

Entregas del curso de Data Analytics.

| Módulo | Archivo | Base de datos |
|--------|---------|---------------|
| M4 - Consultas SQL de negocio | `m4_consultas_negocio.sql` | `Ventas_Tech_DB` |
| M5 - Consultas con JOINs | `m5_consultas_joins.sql` | `RetailPro_DB` |

## Nota sobre las bases de datos

- **M4** se resolvió sobre `Ventas_Tech_DB`, el esquema creado en el Checkpoint del Módulo 3 (34 ventas, enero a junio de 2024).
- **M5** se resolvió sobre `RetailPro_DB`, la base del curso (`recursos/base-de-datos/retailpro_db_sqlserver.sql`). Se eligió porque incluye las dimensiones que pide la consigna (región, segmento y canal), tiene clientes y productos sin ventas para las consultas con `LEFT JOIN ... IS NULL`, y es la base que se conecta a Power BI en M6 y M7.

## Cómo ejecutar el M5

1. Crear la base ejecutando `retailpro_db_sqlserver.sql` en SSMS (F5).
2. Abrir `m5_consultas_joins.sql` y ejecutarlo. Devuelve 4 resultados, uno por consulta.
