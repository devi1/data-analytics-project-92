-- Отчет: Количество покупателей по возрастным группам (16-25, 26-40, 40+)
SELECT
    age_category,
    COUNT(*) AS age_count
FROM (
    SELECT
        CASE
            WHEN age BETWEEN 16 AND 25 THEN '16-25'
            WHEN age BETWEEN 26 AND 40 THEN '26-40'
            ELSE '40+'
        END AS age_category,
        CASE
            WHEN age BETWEEN 16 AND 25 THEN 1
            WHEN age BETWEEN 26 AND 40 THEN 2
            ELSE 3
        END AS sort_key
    FROM customers
) t
GROUP BY age_category, sort_key
ORDER BY sort_key;


-- Отчет: Количество уникальных покупателей и выручка по месяцам (YYYY-MM)
SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales s
JOIN products p ON p.product_id = s.product_id
GROUP BY selling_month
ORDER BY selling_month ASC;


-- Отчет: Покупатели, чья первая покупка была во время акции (цена товара = 0)
WITH first_purchase AS (
    SELECT
        s.customer_id,
        MIN(s.sale_date) AS first_sale_date
    FROM sales s
    GROUP BY s.customer_id
),
first_day_sales AS (
    SELECT
        fp.customer_id,
        fp.first_sale_date,
        s.sales_person_id,
        p.price
    FROM first_purchase fp
    JOIN sales s
        ON s.customer_id = fp.customer_id
       AND s.sale_date = fp.first_sale_date
    JOIN products p
        ON p.product_id = s.product_id
),
promo_customers AS (
    SELECT DISTINCT
        customer_id,
        first_sale_date
    FROM first_day_sales
    WHERE price = 0
),
seller_for_first_day AS (
    -- Если в первый день было несколько продавцов, выберем одного детерминированно (минимальный ID)
    SELECT
        fds.customer_id,
        fds.first_sale_date,
        MIN(fds.sales_person_id) AS sales_person_id
    FROM first_day_sales fds
    GROUP BY fds.customer_id, fds.first_sale_date
)
SELECT
    TRIM(CONCAT(c.first_name, ' ', c.last_name)) AS customer,
    pc.first_sale_date AS sale_date,
    TRIM(CONCAT(e.first_name, ' ', e.last_name)) AS seller
FROM promo_customers pc
JOIN seller_for_first_day sfd
    ON sfd.customer_id = pc.customer_id
   AND sfd.first_sale_date = pc.first_sale_date
JOIN customers c
    ON c.customer_id = pc.customer_id
JOIN employees e
    ON e.employee_id = sfd.sales_person_id
ORDER BY pc.customer_id ASC;
