# 📊 RetailPro | Proyecto Integrador de Data Analytics

## 📌 Descripción del proyecto

Este repositorio contiene el desarrollo del **Proyecto Integrador del curso de Data Analytics**, basado en el análisis de ventas de **RetailPro**, una empresa distribuidora de tecnología.

El objetivo del proyecto es aplicar herramientas y técnicas de análisis de datos para transformar información comercial en conocimiento útil para la toma de decisiones.

A lo largo de los distintos módulos se trabaja con la creación y gestión de bases de datos, consultas SQL, limpieza y transformación de datos, modelado dimensional y análisis mediante Power BI.

El proyecto contempla las siguientes etapas:

- Creación y carga de bases de datos en SQL Server.
- Desarrollo de consultas SQL para responder preguntas de negocio.
- Análisis de ventas, productos y comportamiento de clientes.
- Limpieza y transformación de datos mediante Power Query.
- Construcción de un modelo dimensional tipo estrella.
- Creación de medidas y cálculos utilizando DAX.
- Preparación de datos para su análisis y visualización.

## 🛠️ Herramientas utilizadas

| Herramienta | Aplicación |
|---|---|
| SQL Server | Creación y administración de bases de datos. |
| SQL Server Management Studio (SSMS) | Ejecución y desarrollo de consultas SQL. |
| Excel | Exploración y manejo de datos. |
| Power BI Desktop | Limpieza, modelado y análisis de datos. |
| Power Query | Transformación y preparación de datos. |
| DAX | Creación de medidas y cálculos analíticos. |
| GitHub | Control de versiones y documentación del proyecto. |

## 📁 Estructura del repositorio

```text
analisis-datos-curso/
│
├── modulo-3/
│   └── ventas_tech_db.sql
│
├── RetailPro/
│   ├── m4_consultas_negocio.sql
│   └── m5_consultas_joins.sql
│
├── M6-Pipeline-ETL/
│   ├── Pipeline_ETL_Jofre_Leandro.pbix
│   └── Pipeline_ETL_Jofre_Leandro.pdf
│
├── M8-Modelo-DAX/
│   └── Jofre_Leandro_Checkpoint2.pbix
│
└── README.md
```

### Descripción de las carpetas

**📂 modulo-3/**
- `ventas_tech_db.sql`: script para crear las tablas y cargar los datos iniciales en SQL Server, dentro de la base de datos `Ventas_Tech_DB`.

**📂 RetailPro/**
- `m4_consultas_negocio.sql`: consultas orientadas al análisis comercial, sobre la base `Ventas_Tech_DB`:
  - Resumen mensual de ventas.
  - Ranking de productos.
  - Identificación de clientes recurrentes.
  - Comparación de ventas mensuales contra el promedio.
- `m5_consultas_joins.sql`: consultas utilizando `JOIN` y `UNION ALL` para relacionar y combinar información de distintas tablas de `RetailPro_DB`.

**📂 M6-Pipeline-ETL/**
- Archivo de Power BI (`.pbix`) y documentación PDF correspondientes al proceso ETL.
- Limpieza, transformación y preparación de datos mediante Power Query.

**📂 M8-Modelo-DAX/**
- Archivo de Power BI con el modelo dimensional tipo estrella.
- Construcción de la tabla calendario.
- Desarrollo de medidas y cálculos utilizando DAX.

## 🚀 Cómo ejecutar el proyecto

Para reproducir los análisis, se recomienda seguir el orden de ejecución de los siguientes pasos.

### 1. Preparar el entorno

Instalar y disponer de las siguientes herramientas:

- SQL Server.
- SQL Server Management Studio (SSMS).
- Power BI Desktop.

Clonar o descargar este repositorio desde GitHub.

### 2. Crear y cargar la base de datos Ventas_Tech_DB

1. Abrir SQL Server Management Studio y conectarse a la instancia de SQL Server.
2. Crear la base de datos (el script no la crea: la línea `CREATE DATABASE` está comentada):

   ```sql
   CREATE DATABASE Ventas_Tech_DB;
   ```

3. Seleccionar `Ventas_Tech_DB` en el desplegable de bases de datos de SSMS. El script no incluye `USE`, así que si no se selecciona la base, las tablas se crean en la base activa (por defecto, `master`).
4. Abrir el archivo `modulo-3/ventas_tech_db.sql` y ejecutarlo completo (F5).
5. Verificar la carga con las consultas de validación del final del script: 4 categorías, 5 clientes, 6 productos y 10 ventas.

### 3. Ejecutar las consultas de negocio

Abrir el archivo `RetailPro/m4_consultas_negocio.sql`, **con `Ventas_Tech_DB` seleccionada** (el archivo no incluye `USE`).

Ejecutar las consultas para obtener información sobre:

- Evolución mensual de la facturación.
- Cantidad de pedidos y ticket promedio.
- Productos con mayor rendimiento.
- Clientes recurrentes.
- Comparación de resultados mensuales respecto del promedio.

### 4. Crear RetailPro_DB y ejecutar las consultas con JOIN y UNION ALL

1. Crear la base `RetailPro_DB` ejecutando el script `retailpro_db_sqlserver.sql` provisto por el curso (carpeta `recursos/base-de-datos` del repositorio de la cursada). El script crea la base, las tablas con sus claves primarias, claves foráneas e índices, y carga los datos de 2023 y 2024.
2. Abrir `RetailPro/m5_consultas_joins.sql` y ejecutarlo. Este archivo ya incluye `USE RetailPro_DB;`.
3. Control: la Consulta 1 (vista base con `INNER JOIN`) debe devolver **1.444 filas**, una por venta.

### 5. Revisar el proceso ETL en Power BI

Ingresar a la carpeta `M6-Pipeline-ETL/` y abrir el archivo `.pbix` con Power BI Desktop.

En esta etapa se puede revisar el proceso de extracción, limpieza y transformación de datos realizado mediante Power Query. También se incluye documentación en formato PDF.

**Importante:** el modelo se alimenta del archivo `Pipeline_ETL_Dataset.xlsx` (dataset del curso), que no está incluido en este repositorio. Para actualizar los datos, hay que descargar ese Excel y apuntar el origen a la nueva ubicación desde *Transformar datos → Configuración de origen de datos → Cambiar origen*.

### 6. Revisar el modelo dimensional y las medidas DAX

Ingresar a la carpeta `M8-Modelo-DAX/` y abrir el archivo `.pbix` (usa el mismo Excel que el paso 5).

En esta etapa se desarrolla:

- Modelo de datos tipo estrella.
- Relaciones entre tablas.
- Tabla calendario.
- Medidas y cálculos mediante DAX.

## 🎯 Objetivos de aprendizaje

Este proyecto integrador permite poner en práctica conocimientos fundamentales de Data Analytics:

- Diseño y administración de bases de datos relacionales.
- Escritura y optimización de consultas SQL.
- Análisis exploratorio de datos.
- Aplicación de funciones de agregación y relaciones entre tablas.
- Procesos ETL y transformación de información.
- Modelado dimensional.
- Creación de indicadores mediante DAX.
- Organización y documentación de proyectos utilizando GitHub.

## 👨‍💻 Autor

**Leandro Jofre** · Curso de Data Analytics – Coderhouse.

**Repositorio:** `analisis-datos-curso`

---

*Proyecto académico con fines educativos. Este README fue generado con asistencia de IA (ChatGPT) y revisado y corregido por el autor contra los scripts del repositorio.*
