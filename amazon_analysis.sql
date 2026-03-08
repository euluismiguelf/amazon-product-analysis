-- ============================================
-- AMAZON PRODUCT ANALYSIS | PostgreSQL
-- Autor: Luis Miguel Ferreira Fernández
-- Fecha: 2026
-- Dataset: Amazon India Products & Reviews
-- ============================================

-- PREPARACIÓN
-- ============================================

-- Crear tabla principal
CREATE TABLE amazon_products (
    product_id        TEXT,
    product_name      TEXT,
    category          TEXT,
    discounted_price  TEXT,
    actual_price      TEXT,
    discount_percentage TEXT,
    rating            TEXT,
    rating_count      TEXT,
    about_product     TEXT,
    user_id           TEXT,
    user_name         TEXT,
    review_id         TEXT,
    review_title      TEXT,
    review_content    TEXT,
    img_link          TEXT,
    product_link      TEXT
);

-- Crear vista limpia
CREATE VIEW amazon_clean AS
SELECT
    product_id,
    product_name,
    -- Tomar solo la categoría principal (antes del primer |)
    SPLIT_PART(category, '|', 1) AS category_main,
    -- Tomar subcategoría
    SPLIT_PART(category, '|', 2) AS category_sub,
    -- Limpiar precio con descuento: quitar ₹ y comas, convertir a número
    CAST(
        REPLACE(REPLACE(discounted_price, '₹', ''), ',', '') 
    AS NUMERIC) AS discounted_price,
    -- Limpiar precio original
    CAST(
        REPLACE(REPLACE(actual_price, '₹', ''), ',', '') 
    AS NUMERIC) AS actual_price,
    -- Limpiar porcentaje: quitar % y convertir a número
    CAST(
        REPLACE(discount_percentage, '%', '') 
    AS NUMERIC) AS discount_pct,
    -- Convertir rating a número
    CAST(rating AS NUMERIC) AS rating,
    -- Limpiar rating_count: quitar comas y convertir a entero
    CAST(
        REPLACE(rating_count, ',', '') 
    AS INTEGER) AS rating_count
FROM amazon_products
WHERE rating != 'ratings'  -- excluir filas con datos sucios
  AND rating_count IS NOT NULL;

-- ANÁLISIS BÁSICO
-- ============================================

-- Consulta 1: Categorías únicas
SELECT DISTINCT category_main
FROM amazon_clean
ORDER BY category_main;

-- Consulta 2: Productos con >50% descuento
SELECT 
    product_name,
    actual_price,
    discounted_price,
    discount_pct
FROM amazon_clean
WHERE discount_pct > 50
ORDER BY discount_pct DESC;

-- Consulta 3: Productos mejor valorados
SELECT 
    product_name,
    rating,
    rating_count,
    discounted_price
FROM amazon_clean
WHERE rating >= 4.5
ORDER BY rating_count DESC
LIMIT 10;

-- Consulta 4: Procutos más baratos (Top 10)
SELECT 
    product_name,
    category_main,
    discounted_price,
    rating
FROM amazon_clean
ORDER BY discounted_price ASC
LIMIT 10;

-- Consulta 5: Productos más caros (Top 10)
SELECT 
    product_name,
    category_main,
    actual_price,
    discounted_price,
    discount_pct
FROM amazon_clean
ORDER BY actual_price DESC
LIMIT 10;

-- ANÁLISIS INTERMEDIO
-- ============================================

-- Consulta 6: Promedio de rating por categoría
SELECT 
    category_main,
    ROUND(AVG(rating), 2)       AS avg_rating,
    ROUND(AVG(discount_pct), 1) AS avg_discount,
    COUNT(*)                     AS total_products
FROM amazon_clean
GROUP BY category_main
ORDER BY avg_rating DESC;

-- Consulta 7: Top 10 productos con más reseñas
SELECT 
    product_name,
    category_main,
    rating_count,
    rating,
    discounted_price
FROM amazon_clean
ORDER BY rating_count DESC
LIMIT 10;

-- Consulta 8: Categoría con mayor descuento promedio
SELECT 
    category_main,
    ROUND(AVG(discount_pct), 1) AS avg_discount,
    MAX(discount_pct)            AS max_discount,
    MIN(discount_pct)            AS min_discount,
    COUNT(*)                     AS total_products
FROM amazon_clean
GROUP BY category_main
ORDER BY avg_discount DESC;

-- Consulta 9: Categorías con más de 100 productos
SELECT 
    category_main,
    COUNT(*) AS total_products,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROUND(AVG(discount_pct), 1) AS avg_discount
FROM amazon_clean
GROUP BY category_main
HAVING COUNT(*) > 100
ORDER BY total_products DESC;

-- Consulta 10: Ahorro promedio por categoría
SELECT 
    category_main,
    ROUND(AVG(actual_price), 0)      AS avg_original_price,
    ROUND(AVG(discounted_price), 0)  AS avg_discounted_price,
    ROUND(AVG(actual_price - discounted_price), 0) AS avg_savings
FROM amazon_clean
GROUP BY category_main
ORDER BY avg_savings DESC;

-- ANÁLISIS AVANZADO
-- ============================================

-- Consulta 11: Clasificar Productos por nivel de descuento
SELECT 
    product_name,
    category_main,
    discount_pct,
    rating,
    CASE 
        WHEN discount_pct >= 70 THEN 'Descuento Alto'
        WHEN discount_pct >= 40 THEN 'Descuento Medio'
        WHEN discount_pct >= 10 THEN 'Descuento Bajo'
        ELSE 'Sin Descuento'
    END AS nivel_descuento
FROM amazon_clean
ORDER BY discount_pct DESC;

-- Consulta 12: ¿Cuántos productos hay en cada nivel de descuento?
SELECT 
    CASE 
        WHEN discount_pct >= 70 THEN 'Descuento Alto'
        WHEN discount_pct >= 40 THEN 'Descuento Medio'
        WHEN discount_pct >= 10 THEN 'Descuento Bajo'
        ELSE 'Sin Descuento'
    END AS nivel_descuento,
    COUNT(*) AS total_productos,
    ROUND(AVG(rating), 2) AS avg_rating
FROM amazon_clean
GROUP BY nivel_descuento
ORDER BY total_productos DESC;

-- Consulta 13: Ranking de productos dentro de su categoría
SELECT 
    product_name,
    category_main,
    rating,
    rating_count,
    RANK() OVER (
        PARTITION BY category_main 
        ORDER BY rating DESC
    ) AS ranking_en_categoria
FROM amazon_clean
WHERE rating_count > 1000
ORDER BY category_main, ranking_en_categoria;

-- Consulta 14: Productos con rating sobre el promedio de su categoría
SELECT 
    a.product_name,
    a.category_main,
    a.rating,
    ROUND(b.avg_category_rating, 2) AS avg_categoria,
    ROUND(a.rating - b.avg_category_rating, 2) AS diferencia
FROM amazon_clean a
JOIN (
    SELECT 
        category_main,
        AVG(rating) AS avg_category_rating
    FROM amazon_clean
    GROUP BY category_main
) b ON a.category_main = b.category_main
WHERE a.rating > b.avg_category_rating
ORDER BY diferencia DESC
LIMIT 20;

-- Consulta 15: Resumen Ejecutivo Completo
WITH resumen AS (
    SELECT 
        category_main,
        COUNT(*) AS total_productos,
        ROUND(AVG(rating), 2) AS avg_rating,
        ROUND(AVG(discount_pct), 1) AS avg_descuento,
        ROUND(AVG(discounted_price), 0) AS precio_promedio,
        SUM(rating_count) AS total_resenas
    FROM amazon_clean
    GROUP BY category_main
)
SELECT 
    category_main,
    total_productos,
    avg_rating,
    avg_descuento,
    precio_promedio,
    total_resenas,
    RANK() OVER (ORDER BY avg_rating DESC) AS rank_rating,
    RANK() OVER (ORDER BY total_resenas DESC) AS rank_popularidad
FROM resumen
ORDER BY rank_rating;