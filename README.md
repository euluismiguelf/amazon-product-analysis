# 🛒 Amazon Product Analysis | SQL + PostgreSQL

## 📋 Descripción
Análisis de 1,462 productos de Amazon India usando PostgreSQL.
El proyecto explora ratings, descuentos y popularidad por categoría.

## 🎯 Preguntas de Negocio Respondidas
- ¿Qué categoría tiene el mejor rating promedio?
- ¿Los productos con más descuento tienen mejor o peor rating?
- ¿Cuáles son los productos más populares por reseñas?
- ¿Qué categoría ofrece el mayor ahorro al consumidor?

## 🔍 Principales Hallazgos
- Electronics lidera en popularidad con +15.7M reseñas totales
- Productos SIN descuento tienen mejor rating (4.21) que los 
  con descuento alto (4.03)
- Computers&Accessories es la categoría más equilibrada:
  buen rating (4.16) y alta popularidad
- AmazonBasics HDMI es el producto más reseñado (426,973)
- 47% de los productos tienen más del 50% de descuento

## 🛠️ Herramientas y Conceptos
- PostgreSQL + pgAdmin
- Limpieza de datos con REGEXP_REPLACE
- SELECT, WHERE, ORDER BY, GROUP BY, HAVING
- CASE WHEN, Window Functions (RANK, PARTITION BY)
- Subconsultas, JOINs, CTEs

## 📁 Archivos
| Archivo | Descripción |
|---------|-------------|
| amazon_analysis.sql | Todas las consultas documentadas |
| data/amazon.csv | Dataset original |
| resultados/ | CSVs con resultados clave |

## 📌 Dataset
Fuente: Amazon India Products Dataset - Kaggle
