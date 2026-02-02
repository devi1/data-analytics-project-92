-- Отчет 1: Топ-10 продавцов по суммарной выручке, с количеством сделок
SELECT
    TRIM(CONCAT(e.first_name, ' ', e.last_name)) AS seller,
    COUNT(*) AS operations,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales s
JOIN employees e ON e.employee_id = s.sales_person_id
JOIN products p ON p.product_id = s.product_id
GROUP BY seller
ORDER BY income DESC
LIMIT 10;


-- Отчет 2: Продавцы, чья средняя выручка за сделку ниже средней по всем продавцам
WITH seller_stats AS (
    SELECT
        TRIM(CONCAT(e.first_name, ' ', e.last_name)) AS seller,
        SUM(s.quantity * p.price) AS total_income,
        COUNT(*) AS operations
    FROM sales s
    JOIN employees e ON e.employee_id = s.sales_person_id
    JOIN products p ON p.product_id = s.product_id
    GROUP BY seller
),
global_stats AS (
    SELECT
        SUM(s.quantity * p.price) / COUNT(*)::numeric AS global_avg_income
    FROM sales s
    JOIN products p ON p.product_id = s.product_id
)
SELECT
    ss.seller,
    FLOOR(ss.total_income / ss.operations) AS average_income
FROM seller_stats ss
CROSS JOIN global_stats gs
WHERE (ss.total_income / ss.operations) < gs.global_avg_income
ORDER BY average_income ASC, ss.seller;


-- Отчет 3: Выручка по дням недели для каждого продавца (сортировка: monday..sunday, затем seller)
SELECT
    TRIM(CONCAT(e.first_name, ' ', e.last_name)) AS seller,
    LOWER(TO_CHAR(s.sale_date, 'FMday')) AS day_of_week,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales s
JOIN employees e ON e.employee_id = s.sales_person_id
JOIN products p ON p.product_id = s.product_id
GROUP BY
    seller,
    day_of_week,
    ( (EXTRACT(DOW FROM s.sale_date)::int + 6) % 7 )
ORDER BY
    ( (EXTRACT(DOW FROM s.sale_date)::int + 6) % 7 ) ASC,
    seller ASC;
