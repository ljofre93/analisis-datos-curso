/* =====================================================================
   PROYECTO FINAL - EJERCICIO SQL
   04) Consulta solicitada: ventas de los últimos 30 días
   - Extrae nombre del cliente, fecha de compra y total de la venta.
   - "Últimos 30 días" se calcula de forma DINÁMICA a partir de la última
     fecha de compra del dataset (MAX), sin escribir ninguna fecha a mano.
   - Ordena por fecha de compra descendente.
   ===================================================================== */
USE ProyectoFinal_Jofre;
GO

SELECT
    c.nombre_completo   AS nombre_cliente,
    v.fecha_compra,
    v.total_venta
FROM dbo.Ventas  AS v
INNER JOIN dbo.Cliente AS c
    ON v.id_cliente = c.id_cliente
WHERE v.fecha_compra >= DATEADD(DAY, -30, (SELECT MAX(fecha_compra) FROM dbo.Ventas))
ORDER BY v.fecha_compra DESC;

-- Control: período considerado y cantidad de ventas devueltas
SELECT
    DATEADD(DAY, -30, MAX(fecha_compra))  AS desde,
    MAX(fecha_compra)                     AS hasta,
    (SELECT COUNT(*) FROM dbo.Ventas
     WHERE fecha_compra >= DATEADD(DAY, -30, (SELECT MAX(fecha_compra) FROM dbo.Ventas))) AS ventas_ultimos_30_dias
FROM dbo.Ventas;
