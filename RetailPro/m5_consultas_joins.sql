-- =====================================================================
-- M5 - Consultas con JOINs para el proyecto
-- Cruzando tablas para enriquecer el análisis
-- Base: Ventas_Tech_DB (esquema del Checkpoint del Módulo 3)
-- =====================================================================

USE Ventas_Tech_DB;
GO

-- =====================================================================
-- Datos de prueba para las consultas 2 y 3
-- En el dataset todos los clientes compraron y todos los productos
-- se vendieron, así que agrego un cliente sin compras y un producto
-- sin ventas. Con IF NOT EXISTS se puede ejecutar más de una vez.
-- =====================================================================
IF NOT EXISTS (SELECT 1 FROM clientes WHERE id_cliente = 6)
    INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro)
    VALUES (6, N'Julián Pérez', N'julian@mail.com', N'La Plata', '2024-06-20');

IF NOT EXISTS (SELECT 1 FROM productos WHERE id_producto = 7)
    INSERT INTO productos (id_producto, nombre_producto, id_categoria, precio, stock, activo)
    VALUES (7, N'Webcam Full HD', 2, 60.00, 25, 1);
GO

-- Consulta 1: Vista base del proyecto (INNER JOIN)
SELECT
    v.id_venta,
    v.fecha_venta,
    c.id_cliente,
    c.nombre                          AS cliente,
    c.ciudad,
    p.nombre_producto                 AS producto,
    cat.nombre_categoria              AS categoria,
    v.cantidad,
    v.precio_unitario,
    v.cantidad * v.precio_unitario    AS total_venta
FROM ventas AS v
INNER JOIN clientes AS c
    ON v.id_cliente = c.id_cliente
INNER JOIN productos AS p
    ON v.id_producto = p.id_producto
INNER JOIN categorias AS cat
    ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta, v.id_venta;

-- Consulta 2: Clientes sin ventas (LEFT JOIN)
SELECT
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes AS c
LEFT JOIN ventas AS v
    ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL
ORDER BY c.fecha_registro;

-- Consulta 3: Productos sin ventas (LEFT JOIN)
SELECT
    p.nombre_producto,
    cat.nombre_categoria              AS categoria,
    p.precio
FROM productos AS p
INNER JOIN categorias AS cat
    ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas AS v
    ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL
ORDER BY p.nombre_producto;

-- Consulta 4: Consolidado por canal (UNION ALL)
-- El canal no existe en las tablas: se crea como texto fijo en cada SELECT.
-- Criterio: dos períodos (1er trimestre ene-mar / 2do trimestre abr-jun 2024).
SELECT
    canal,
    COUNT(*)                          AS cantidad_ventas,
    SUM(total)                        AS total_canal
FROM (
    SELECT
        fecha_venta,
        cantidad * precio_unitario    AS total,
        '1er trimestre'               AS canal
    FROM ventas
    WHERE fecha_venta >= '2024-01-01' AND fecha_venta < '2024-04-01'

    UNION ALL

    SELECT
        fecha_venta,
        cantidad * precio_unitario    AS total,
        '2do trimestre'               AS canal
    FROM ventas
    WHERE fecha_venta >= '2024-04-01' AND fecha_venta < '2024-07-01'
) AS consolidado
GROUP BY canal
ORDER BY canal;

-- =====================================================================
-- Hallazgos
-- =====================================================================
-- 1. La vista base reúne las 34 ventas con cliente, ciudad, producto y
--    categoría en una sola fila. Computación concentra $12.000 de los
--    $17.028 facturados (≈70%).
-- 2. Julián Pérez (La Plata) está registrado pero nunca compró:
--    es un cliente a contactar desde CRM.
-- 3. Webcam Full HD (Accesorios) no registra ventas: producto sin
--    movimiento en el catálogo.
-- 4. El 2do trimestre facturó $8.798 en 15 ventas y el 1er trimestre
--    $8.230 en 19 ventas: menos operaciones pero mayor facturación
--    (≈7% más), impulsada por ventas de mayor valor.
