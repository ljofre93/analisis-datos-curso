/* =====================================================================
   PROYECTO FINAL - EJERCICIO SQL
   02) Análisis exploratorio (EDA) sobre los datos crudos
   Objetivo: conocer el dataset y detectar problemas de calidad ANTES
   de escribir la consulta. Cada bloque indica el resultado obtenido.
   ===================================================================== */
USE ProyectoFinal_Jofre;
GO

-- EDA 1. Volumen y período de las ventas
--        Resultado: 1.762 ventas entre el 01/07/2018 y el 01/12/2019.
SELECT
    COUNT(*)                                          AS ventas,
    MIN(CONVERT(DATE, [Fecha compra], 103))           AS primera_compra,
    MAX(CONVERT(DATE, [Fecha compra], 103))           AS ultima_compra
FROM dbo.stg_ventas;

-- EDA 2. Valores vacíos en las columnas que usa la consulta
--        Resultado: 0 vacíos en cliente, fecha, valor unidad y cantidad.
SELECT
    SUM(CASE WHEN NULLIF(LTRIM(RTRIM([ID_Cliente ])), '')   IS NULL THEN 1 ELSE 0 END) AS cliente_vacio,
    SUM(CASE WHEN NULLIF(LTRIM(RTRIM([Fecha compra])), '')  IS NULL THEN 1 ELSE 0 END) AS fecha_vacia,
    SUM(CASE WHEN NULLIF(LTRIM(RTRIM([Valor Unidad])), '')  IS NULL THEN 1 ELSE 0 END) AS valor_vacio,
    SUM(CASE WHEN NULLIF(LTRIM(RTRIM([Cantidad ])), '')     IS NULL THEN 1 ELSE 0 END) AS cantidad_vacia
FROM dbo.stg_ventas;

-- EDA 3. Formatos: fechas en texto dd/mm/aaaa y decimales con coma
--        Resultado: todas las fechas convierten con el estilo 103;
--        el valor unitario va de 1,09 a 26,995 (coma decimal).
SELECT TOP 5
    [Fecha compra], [Valor Unidad], [Cantidad ],
    TRY_CONVERT(DATE, [Fecha compra], 103)                      AS fecha_convertida,
    TRY_CAST(REPLACE([Valor Unidad], ',', '.') AS DECIMAL(10,3)) AS valor_convertido
FROM dbo.stg_ventas;

SELECT
    SUM(CASE WHEN TRY_CONVERT(DATE, [Fecha compra], 103) IS NULL THEN 1 ELSE 0 END)                        AS fechas_invalidas,
    SUM(CASE WHEN TRY_CAST(REPLACE([Valor Unidad], ',', '.') AS DECIMAL(10,3)) IS NULL THEN 1 ELSE 0 END)  AS valores_invalidos
FROM dbo.stg_ventas;

-- EDA 4. Clientes duplicados: mismo DNI con dos id_Cliente distintos
--        Resultado: 62 DNI repetidos (124 filas). En cada par, el
--        descuento de uno es el del otro multiplicado por 100.
SELECT
    [DNI ]                          AS dni,
    COUNT(*)                        AS veces,
    STRING_AGG([id_Cliente], ' / ') AS ids,
    STRING_AGG([Descuento ], ' / ') AS descuentos,
    MIN([Nombre completo ])         AS nombre
FROM dbo.stg_cliente
GROUP BY [DNI ]
HAVING COUNT(*) > 1
ORDER BY nombre;

-- EDA 5. ¿Las ventas usan los dos ID de un mismo cliente?
--        Resultado: en 33 de los 62 pares hay ventas cargadas con ambos ID.
--        No alcanza con borrar el duplicado: hay que reasignar esas ventas.
WITH dup AS (
    SELECT [DNI ] AS dni, [id_Cliente] AS id_cliente
    FROM dbo.stg_cliente
    WHERE [DNI ] IN (SELECT [DNI ] FROM dbo.stg_cliente GROUP BY [DNI ] HAVING COUNT(*) > 1)
)
SELECT COUNT(*) AS pares_con_ventas_en_ambos_ids
FROM (
    SELECT d.dni
    FROM dup d
    WHERE EXISTS (SELECT 1 FROM dbo.stg_ventas v WHERE LTRIM(RTRIM(v.[ID_Cliente ])) = d.id_cliente)
    GROUP BY d.dni
    HAVING COUNT(*) = 2
) x;

-- EDA 6. Descuentos fuera de rango (deberían estar entre 0 y 100)
--        Resultado: 94 clientes con descuento > 100 (60 en los pares
--        duplicados y 34 clientes únicos). Ej.: 4800 en lugar de 48.
--        En 2 pares el valor inflado es justo 100 (1 vs 100), por eso no
--        entran en este conteo: se resuelven con la deduplicación.
SELECT COUNT(*) AS descuentos_fuera_de_rango
FROM dbo.stg_cliente
WHERE CAST([Descuento ] AS INT) > 100;

-- EDA 7. Errores de tipeo en Ocupación
--        Resultado: Medicoo, Economistaa, Floristaa, Cocinar, Interpreter.
SELECT [Ocupación] AS ocupacion, COUNT(*) AS clientes
FROM dbo.stg_cliente
WHERE [Ocupación] IN (N'Medico', N'Medicoo', N'Economista', N'Economistaa',
                      N'Florista', N'Floristaa', N'Cocinar', N'Cocinero', N'Interpreter')
GROUP BY [Ocupación]
ORDER BY [Ocupación];

-- EDA 8. Vendedores: nombres sin registrar y valores inconsistentes
--        Resultado: 3 vendedores "Sin Registro" (sin ventas asociadas),
--        1 género escrito en minúscula ("femenino") y 59 contratos con
--        el error de tipeo "Indefenido".
--        COLLATE ..._CS_AS hace la comparación sensible a mayúsculas.
SELECT N'Nombre = "Sin Registro"' AS problema, COUNT(*) AS vendedores
FROM dbo.stg_vendedor
WHERE [Nombre completo] = N'Sin Registro'
UNION ALL
SELECT N'Género en minúscula ("femenino")', COUNT(*)
FROM dbo.stg_vendedor
WHERE LTRIM(RTRIM([Genero ])) COLLATE Latin1_General_CS_AS = N'femenino'
UNION ALL
SELECT N'Contrato mal escrito ("Indefenido")', COUNT(*)
FROM dbo.stg_vendedor
WHERE LTRIM(RTRIM([Contrato ])) = N'Indefenido';

-- EDA 9. Integridad referencial y fechas incoherentes
--        Resultado: todas las ventas tienen producto, cliente y vendedor
--        existentes; 18 ventas tienen fecha de entrega anterior a la compra.
SELECT
    SUM(CASE WHEN p.[ID_Producto] IS NULL THEN 1 ELSE 0 END)                         AS sin_producto,
    SUM(CASE WHEN c.[id_Cliente]  IS NULL THEN 1 ELSE 0 END)                         AS sin_cliente,
    SUM(CASE WHEN ve.[ID_Vendedor ] IS NULL THEN 1 ELSE 0 END)                       AS sin_vendedor,
    SUM(CASE WHEN CONVERT(DATE, v.[Fecha Entrega], 103)
                < CONVERT(DATE, v.[Fecha compra], 103) THEN 1 ELSE 0 END)            AS entrega_antes_de_compra
FROM dbo.stg_ventas v
LEFT JOIN dbo.stg_productos p  ON p.[ID_Producto]  = v.[ID_Producto]
LEFT JOIN dbo.stg_cliente   c  ON c.[id_Cliente]   = LTRIM(RTRIM(v.[ID_Cliente ]))
LEFT JOIN dbo.stg_vendedor  ve ON ve.[ID_Vendedor ] = LTRIM(RTRIM(v.[ID_Vendedor ]));
