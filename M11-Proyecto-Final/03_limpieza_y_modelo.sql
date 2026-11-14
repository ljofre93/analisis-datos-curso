/* =====================================================================
   PROYECTO FINAL - EJERCICIO SQL
   03) Limpieza y modelo final (tablas con tipos, PK y FK)
   Decisiones de limpieza (cada una responde a un hallazgo del EDA):
     1. Nombres de columna sin espacios, en minúscula y sin acentos.
     2. Fechas de texto dd/mm/aaaa -> DATE (estilo 103).
     3. Decimales con coma -> DECIMAL.
     4. Clientes duplicados por DNI: queda UN registro por DNI (el que
        tiene el descuento correcto) y las ventas del ID descartado se
        reasignan al ID que queda. No se pierde ninguna venta.
     5. Descuentos > 100 (cargados x100) -> se dividen por 100.
     6. Ocupaciones con errores de tipeo -> se corrigen.
     7. Vendedores: género y contrato estandarizados; "Sin Registro" se
        conserva (son 3 vendedores sin ventas) pero queda marcado.
     8. Se agrega total_venta = valor_unidad x cantidad.
     9. Se marcan (no se borran) las 18 ventas con entrega anterior a la compra.
   ===================================================================== */
USE ProyectoFinal_Jofre;
GO

DROP TABLE IF EXISTS dbo.Ventas;
DROP TABLE IF EXISTS dbo.Vendedor;
DROP TABLE IF EXISTS dbo.Sucursal;
DROP TABLE IF EXISTS dbo.Cliente;
DROP TABLE IF EXISTS dbo.Productos;
DROP TABLE IF EXISTS dbo.map_cliente;
GO

/* ---------- Sucursal ---------- */
CREATE TABLE dbo.Sucursal (
    id_sucursal      INT           NOT NULL CONSTRAINT PK_Sucursal PRIMARY KEY,
    nombre_sucursal  NVARCHAR(50)  NOT NULL,
    tipo             NVARCHAR(10)  NOT NULL,   -- B2B / B2C
    zona             NVARCHAR(30)  NOT NULL
);
INSERT INTO dbo.Sucursal
SELECT CAST([ID_Sucursal] AS INT), LTRIM(RTRIM([Nombre suc])), LTRIM(RTRIM([Tamaño])), LTRIM(RTRIM([Zona]))
FROM dbo.stg_sucursal;
GO

/* ---------- Vendedor ---------- */
CREATE TABLE dbo.Vendedor (
    id_vendedor      INT           NOT NULL CONSTRAINT PK_Vendedor PRIMARY KEY,
    nombre_completo  NVARCHAR(100) NOT NULL,
    genero           NVARCHAR(10)  NOT NULL,
    telefono         NVARCHAR(20)  NULL,
    estado_civil     NVARCHAR(15)  NOT NULL,
    contrato         NVARCHAR(15)  NOT NULL,
    id_sucursal      INT           NOT NULL,
    sin_registro     BIT           NOT NULL,
    CONSTRAINT FK_Vendedor_Sucursal FOREIGN KEY (id_sucursal) REFERENCES dbo.Sucursal(id_sucursal)
);
INSERT INTO dbo.Vendedor
SELECT
    CAST(LTRIM(RTRIM([ID_Vendedor ])) AS INT),
    REPLACE(LTRIM(RTRIM([Nombre completo])), N', ', N' '),                     -- "Ted, Gray" -> "Ted Gray"
    CASE WHEN LOWER(LTRIM(RTRIM([Genero ]))) = N'femenino' THEN N'Femenino' ELSE N'Masculino' END,
    LTRIM(RTRIM([Telefono ])),
    CASE WHEN LTRIM(RTRIM([Estado Civil])) = N'Casado' THEN N'Casado/a' ELSE N'Soltero/a' END,
    CASE WHEN LTRIM(RTRIM([Contrato ])) LIKE N'Indef%' THEN N'Indefinido' ELSE N'Fijo' END,
    CAST(LTRIM(RTRIM([id_Sucursal])) AS INT),
    CASE WHEN LTRIM(RTRIM([Nombre completo])) = N'Sin Registro' THEN 1 ELSE 0 END
FROM dbo.stg_vendedor;
GO

/* ---------- Productos ---------- */
CREATE TABLE dbo.Productos (
    id_producto         INT            NOT NULL CONSTRAINT PK_Productos PRIMARY KEY,
    producto            NVARCHAR(100)  NOT NULL,
    descripcion_corta   NVARCHAR(50)   NOT NULL,
    tamano              NVARCHAR(20)   NOT NULL,
    empaque             NVARCHAR(20)   NOT NULL,
    embalaje            NVARCHAR(20)   NOT NULL,
    garantia            BIT            NOT NULL,
    peso_lb             INT            NOT NULL,
    dimensiones_cm      NVARCHAR(20)   NOT NULL
);
INSERT INTO dbo.Productos
SELECT
    CAST([ID_Producto] AS INT),
    LTRIM(RTRIM([Producto])),
    LTRIM(RTRIM([Descripción Abreviada ])),
    LTRIM(RTRIM([Tamaño ])),
    LTRIM(RTRIM([Empaque ])),
    LTRIM(RTRIM([Embalaje])),
    CASE WHEN LTRIM(RTRIM([Garantia ])) = N'Si' THEN 1 ELSE 0 END,
    CAST([Peso Lb] AS INT),
    LTRIM(RTRIM([Dimensiones Cm]))
FROM dbo.stg_productos;
GO

/* ---------- Cliente: deduplicación por DNI ----------
   map_cliente guarda, para cada id original, el id que se conserva.
   Por cada DNI se queda el registro con el descuento MENOR (el correcto:
   el duplicado tiene el mismo descuento multiplicado por 100).          */
CREATE TABLE dbo.map_cliente (
    id_original  INT NOT NULL CONSTRAINT PK_map_cliente PRIMARY KEY,
    id_final     INT NOT NULL
);
WITH c AS (
    SELECT
        CAST([id_Cliente] AS INT)  AS id_cliente,
        LTRIM(RTRIM([DNI ]))       AS dni,
        CAST([Descuento ] AS INT)  AS descuento,
        ROW_NUMBER() OVER (PARTITION BY LTRIM(RTRIM([DNI ]))
                           ORDER BY CAST([Descuento ] AS INT), CAST([id_Cliente] AS INT)) AS orden
    FROM dbo.stg_cliente
)
INSERT INTO dbo.map_cliente (id_original, id_final)
SELECT c.id_cliente, k.id_cliente
FROM c
INNER JOIN c AS k ON k.dni = c.dni AND k.orden = 1;
GO

CREATE TABLE dbo.Cliente (
    id_cliente         INT            NOT NULL CONSTRAINT PK_Cliente PRIMARY KEY,
    dni                INT            NOT NULL CONSTRAINT UQ_Cliente_DNI UNIQUE,
    nombre_completo    NVARCHAR(100)  NOT NULL,
    nombre             NVARCHAR(50)   NOT NULL,
    telefono           NVARCHAR(20)   NULL,
    email              NVARCHAR(100)  NULL,
    genero             CHAR(1)        NOT NULL,
    ocupacion          NVARCHAR(50)   NOT NULL,
    educacion          NVARCHAR(20)   NOT NULL,
    descuento_pct      DECIMAL(5,2)   NOT NULL,
    codigo_frecuente   INT            NULL
);
INSERT INTO dbo.Cliente
SELECT
    CAST(s.[id_Cliente] AS INT),
    CAST(LTRIM(RTRIM(s.[DNI ])) AS INT),
    REPLACE(LTRIM(RTRIM(s.[Nombre completo ])), N'-', N' '),               -- "Sophia-Johnson" -> "Sophia Johnson"
    LTRIM(RTRIM(s.[Nombre ])),
    LTRIM(RTRIM(s.[Número de contacto ])),
    LTRIM(RTRIM(s.[Email ])),
    LTRIM(RTRIM(s.[Género])),
    CASE LTRIM(RTRIM(s.[Ocupación]))
        WHEN N'Medicoo'     THEN N'Médico'
        WHEN N'Medico'      THEN N'Médico'
        WHEN N'Economistaa' THEN N'Economista'
        WHEN N'Floristaa'   THEN N'Florista'
        WHEN N'Cocinar'     THEN N'Cocinero'
        WHEN N'Interpreter' THEN N'Intérprete'
        ELSE LTRIM(RTRIM(s.[Ocupación]))
    END,
    LTRIM(RTRIM(s.[Educación])),
    CASE WHEN CAST(s.[Descuento ] AS INT) > 100
         THEN CAST(s.[Descuento ] AS INT) / 100.0                         -- 4800 -> 48
         ELSE CAST(s.[Descuento ] AS INT) END,
    TRY_CAST(s.[Código cliente frecuente] AS INT)
FROM dbo.stg_cliente s
INNER JOIN dbo.map_cliente m ON m.id_original = CAST(s.[id_Cliente] AS INT)
WHERE m.id_original = m.id_final;                                        -- solo el registro que se conserva
GO

/* ---------- Ventas ---------- */
CREATE TABLE dbo.Ventas (
    id_venta            INT            NOT NULL CONSTRAINT PK_Ventas PRIMARY KEY,
    id_producto         INT            NOT NULL,
    id_cliente          INT            NOT NULL,
    id_ubicacion        INT            NOT NULL,
    id_codigo_pago      INT            NOT NULL,
    id_vendedor         INT            NOT NULL,
    fecha_compra        DATE           NOT NULL,
    fecha_entrega       DATE           NOT NULL,
    fecha_pago          DATE           NOT NULL,
    valor_unidad        DECIMAL(10,3)  NOT NULL,
    cantidad            INT            NOT NULL,
    costos_directos     DECIMAL(10,3)  NOT NULL,
    costos_indirectos   DECIMAL(10,3)  NOT NULL,
    total_venta         AS CAST(valor_unidad * cantidad AS DECIMAL(12,3)) PERSISTED,
    entrega_inconsistente AS CAST(CASE WHEN fecha_entrega < fecha_compra THEN 1 ELSE 0 END AS BIT),
    CONSTRAINT FK_Ventas_Producto FOREIGN KEY (id_producto) REFERENCES dbo.Productos(id_producto),
    CONSTRAINT FK_Ventas_Cliente  FOREIGN KEY (id_cliente)  REFERENCES dbo.Cliente(id_cliente),
    CONSTRAINT FK_Ventas_Vendedor FOREIGN KEY (id_vendedor) REFERENCES dbo.Vendedor(id_vendedor)
);
INSERT INTO dbo.Ventas
    (id_venta, id_producto, id_cliente, id_ubicacion, id_codigo_pago, id_vendedor,
     fecha_compra, fecha_entrega, fecha_pago, valor_unidad, cantidad, costos_directos, costos_indirectos)
SELECT
    CAST(v.[ID_Ventas] AS INT),
    CAST(v.[ID_Producto] AS INT),
    m.id_final,                                                          -- cliente reasignado al ID conservado
    CAST(v.[ID_Ubicación] AS INT),
    CAST(LTRIM(RTRIM(v.[ID_Codigo Pago ])) AS INT),
    CAST(LTRIM(RTRIM(v.[ID_Vendedor ])) AS INT),
    CONVERT(DATE, v.[Fecha compra], 103),
    CONVERT(DATE, v.[Fecha Entrega], 103),
    CONVERT(DATE, LTRIM(RTRIM(v.[Fecha Pago ])), 103),
    CAST(REPLACE(v.[Valor Unidad], ',', '.') AS DECIMAL(10,3)),
    CAST(LTRIM(RTRIM(v.[Cantidad ])) AS INT),
    CAST(REPLACE(v.[Costos Directos ], ',', '.') AS DECIMAL(10,3)),
    CAST(REPLACE(v.[Costos Indirectos ], ',', '.') AS DECIMAL(10,3))
FROM dbo.stg_ventas v
INNER JOIN dbo.map_cliente m ON m.id_original = CAST(LTRIM(RTRIM(v.[ID_Cliente ])) AS INT);
GO

/* ---------- Validación de la limpieza ----------
   Esperado: Sucursal 6 · Vendedor 108 · Productos 96 · Cliente 338
             (400 - 62 duplicados) · Ventas 1762 (no se perdió ninguna).  */
SELECT 'Sucursal' AS tabla, COUNT(*) AS filas FROM dbo.Sucursal
UNION ALL SELECT 'Vendedor',  COUNT(*) FROM dbo.Vendedor
UNION ALL SELECT 'Productos', COUNT(*) FROM dbo.Productos
UNION ALL SELECT 'Cliente',   COUNT(*) FROM dbo.Cliente
UNION ALL SELECT 'Ventas',    COUNT(*) FROM dbo.Ventas;

-- Control de calidad posterior: todo en 0 salvo las 18 entregas marcadas.
SELECT
    (SELECT COUNT(*) FROM (SELECT dni FROM dbo.Cliente GROUP BY dni HAVING COUNT(*) > 1) d) AS dni_duplicados,
    (SELECT COUNT(*) FROM dbo.Cliente WHERE descuento_pct > 100)                         AS descuentos_fuera_de_rango,
    (SELECT COUNT(*) FROM dbo.Cliente WHERE ocupacion IN (N'Medicoo', N'Economistaa', N'Floristaa', N'Cocinar')) AS ocupaciones_con_error,
    (SELECT COUNT(*) FROM dbo.Ventas WHERE entrega_inconsistente = 1)                    AS entregas_marcadas;
