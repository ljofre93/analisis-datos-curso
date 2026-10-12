-- =====================================================================
-- M5 - Consultas con JOINs para el proyecto
-- Cruzando tablas para enriquecer el análisis
-- Base: RetailPro_DB (script del curso: recursos/base-de-datos)
-- =====================================================================

USE RetailPro_DB;
GO

-- Consulta 1: Vista base del proyecto (INNER JOIN)
SELECT
    v.fecha_venta,
    c.id_cliente,
    c.nombre                AS cliente,
    c.segmento,
    t.region,
    p.nombre_producto       AS producto,
    cat.nombre_categoria    AS categoria,
    v.cantidad,
    v.precio_unitario,
    v.total_venta,
    v.canal
FROM ventas AS v
INNER JOIN clientes    AS c   ON v.id_cliente    = c.id_cliente
INNER JOIN productos   AS p   ON v.id_producto   = p.id_producto
INNER JOIN territorios AS t   ON v.id_territorio = t.id_territorio
INNER JOIN categorias  AS cat ON p.id_categoria  = cat.id_categoria
ORDER BY v.fecha_venta;

-- Consulta 2: Clientes sin ventas (LEFT JOIN)
SELECT
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes AS c
LEFT JOIN ventas AS v
    ON c.id_cliente = v.id_cliente
WHERE v.id_cliente IS NULL
ORDER BY c.fecha_registro;

-- Consulta 3: Productos sin ventas (LEFT JOIN)
SELECT
    p.nombre_producto,
    cat.nombre_categoria    AS categoria,
    p.precio
FROM productos AS p
INNER JOIN categorias AS cat
    ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas AS v
    ON p.id_producto = v.id_producto
WHERE v.id_producto IS NULL
ORDER BY p.nombre_producto;

-- Consulta 4: Consolidado por canal (UNION ALL)
-- La columna canal se crea como texto fijo en cada SELECT.
SELECT
    canal,
    COUNT(*)            AS cantidad_ventas,
    SUM(total)          AS total_canal
FROM (
    SELECT
        fecha_venta,
        total_venta     AS total,
        'Online'        AS canal
    FROM ventas
    WHERE canal = 'Online'

    UNION ALL

    SELECT
        fecha_venta,
        total_venta     AS total,
        'Presencial'    AS canal
    FROM ventas
    WHERE canal = 'Presencial'
) AS consolidado
GROUP BY canal
ORDER BY total_canal DESC;

-- =====================================================================
-- Hallazgos
-- =====================================================================
-- 1. La vista base reúne las 1.444 ventas (2023-2024) con cliente,
--    segmento, región, producto, categoría y canal en una sola fila,
--    sin perder registros en los cruces. Es la fuente para Power BI.
-- 2. Hay 4 clientes registrados que nunca compraron (Renata Villalba,
--    Santiago Escobar, Abril Figueroa y Ezequiel Navarro). Se dieron de
--    alta a fines de 2022 y no registran ventas en dos años: son el
--    público objetivo de una acción de CRM.
-- 3. Hay 2 productos sin ventas, ambos de Periféricos. El Hub USB-C 7 en 1
--    está inactivo y sin stock (discontinuado). La Webcam 4K Streaming
--    está activa y con stock, pero nunca se vendió: es el caso a revisar.
-- 4. Presencial factura $308.995,51 en 834 ventas (≈55% del total) y
--    Online $253.576,69 en 610 ventas. Online tiene menos operaciones
--    pero un ticket promedio mayor: $415,70 contra $370,50 presencial.
--    La suma de ambos canales coincide con la facturación total
--    ($562.572,20), lo que confirma que UNION ALL no perdió filas.
