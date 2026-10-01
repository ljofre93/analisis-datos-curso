-- =====================================================================
-- M4 - Consultas SQL de negocio
-- =====================================================================

-- Consulta 1: Resumen ejecutivo mensual
SELECT
    YEAR(fecha_venta)                       AS anio,
    MONTH(fecha_venta)                      AS mes,
    SUM(cantidad * precio_unitario)         AS total_facturado,
    COUNT(*)                                AS cantidad_pedidos,
    AVG(cantidad * precio_unitario)         AS ticket_promedio
FROM ventas
GROUP BY YEAR(fecha_venta), MONTH(fecha_venta)
ORDER BY anio, mes;
;
-- Consulta 2: Ranking de productos (Top 5 por total facturado)
SELECT TOP 5
    id_producto,
    SUM(cantidad)                    AS unidades_vendidas,
    SUM(cantidad * precio_unitario)  AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;
;

-- Consulta 3: Clientes recurrentes (más de un pedido)
SELECT
    id_cliente,
    COUNT(*)                          AS cantidad_pedidos,
    SUM(cantidad * precio_unitario)   AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY cantidad_pedidos DESC;
;

-- Consulta 4: Meses por encima/por debajo del promedio
SELECT
    YEAR(fecha_venta)                       AS anio,
    MONTH(fecha_venta)                      AS mes,
    SUM(cantidad * precio_unitario)         AS total_facturado,
    CASE
        WHEN SUM(cantidad * precio_unitario) >
             (SELECT AVG(total_mes)
              FROM (SELECT SUM(cantidad * precio_unitario) AS total_mes
                    FROM ventas
                    GROUP BY YEAR(fecha_venta), MONTH(fecha_venta)) t)
        THEN 'Por encima'
        ELSE 'Por debajo'
    END                                      AS comparativa
FROM ventas
GROUP BY YEAR(fecha_venta), MONTH(fecha_venta)
ORDER BY anio, mes;

-- =====================================================================
-- Hallazgos
-- =====================================================================
-- 1. El producto 1 (Laptop Pro 15) concentra $8.400 de facturación,
--    más del doble que el segundo producto del ranking (producto 3, $3.600).
-- 2. Marzo fue el mes de mayor facturación ($6.444) y el único mes de
--    enero-febrero-marzo que quedó por encima del promedio general.
-- 3. Los 5 clientes registrados son recurrentes (todos con más de un
--    pedido); María López (cliente 1) es la que más gastó en total ($4.723).